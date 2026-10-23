# PURPOSE: Correct the generated init from lazyvim-nix 2189337 without forking it.
# CONSUMER: lazyvim.nix supplies this file through Home Manager's native source option.
# CUSTOMIZATION: Review these checked replacements when updating lazyvim-nix; do not
# silently accept a changed template. Upstream should own these packaging fixes eventually.
# REMOVAL: See docs/applications/lazyvim.md for each repair's upstream exit condition.
# SECURITY: Nix supplies plugins; disable startup installation and Lua-rock provisioning.
{ lib, pkgs, upstreamInit }:
let
  bootstrap = ''
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
      local lazyrepo = "https://github.com/folke/lazy.nvim.git"
      local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
      if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
          { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
          { out, "WarningMsg" },
          { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
      end
    end
    vim.opt.rtp:prepend(lazypath)
  '';
  # Retain upstream's exact resolved theme revision; its directory is named nvim.
  devMarker = "dev = {\n  path = \"";
  devParts = lib.splitString devMarker upstreamInit;
  devPath = builtins.head (lib.splitString "\"" (builtins.elemAt devParts 1));
  oldTheme = ''{ "nvim", dev = true, pin = true },'';
  setup = ''require("lazy").setup({'';
  installer = ''install = { colorscheme = { "tokyonight", "habamax" } },'';
  expected = [
    "-- Based on LazyVim/starter (commit: 803bc181d7c0d6d5eeba9274d9be49b287294d99)"
    bootstrap devMarker oldTheme setup installer
    "enabled = false, -- [NIX] Disabled - Nix manages plugin versions"
  ];
  once = needle: builtins.length (lib.splitString needle upstreamInit) == 2;
in
if !(lib.all once expected) then
  throw "ijs LazyVim compatibility: upstream initialization template changed; review lazyvim-init.nix before building."
else if !(lib.hasPrefix "${builtins.storeDir}/" devPath) then
  throw "ijs LazyVim compatibility: expected a Nix-managed upstream plugin directory."
else
  lib.replaceStrings
    [ bootstrap oldTheme setup installer ]
    [
      # Load the manager from its real store path, outside Lazy's install root.
      ''vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")
      ''
      ''{ "catppuccin/nvim", name = "catppuccin", dir = "${devPath}/nvim", pin = true },''
      ''require("lazy").setup({
        rocks = { enabled = false }, -- Nix owns Lua dependencies too.
      ''
      ''install = { missing = false, colorscheme = { "tokyonight", "habamax" } },''
    ]
    upstreamInit
  + ''
    -- ijs policy: report an incomplete Nix declaration instead of installing it.
    for name, plugin in pairs(require("lazy.core.config").plugins) do
      if not plugin._.installed then
        error("ijs: missing Nix-managed LazyVim plugin: " .. name)
      end
    end
  ''
