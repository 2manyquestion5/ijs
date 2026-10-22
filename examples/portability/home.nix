# PURPOSE: Share a small development environment between both Home Manager modes.
# CONSUMERS: The standalone portability output and the integrated development VM.
# CUSTOMIZATION: Select user tools here; the caller supplies account and upstream LazyVim wiring.
# SECURITY: No credentials, host services or privileged group memberships belong here.
{ pkgs, lib, ijs, ... }:
{
  imports = [
    ijs.modules.homeManager.lazyvim
    ijs.modules.homeManager.tmux
  ];

  _module.args.theme =
    (ijs.ijs.resolveTheme { inherit lib; }) "mocha-purple";

  programs.git.enable = true;

  # The pinned LazyVim starter bootstraps here, even though Nix packages lazy.nvim.
  # Supply that location declaratively so a fresh home does not clone it at runtime.
  xdg.dataFile."nvim/lazy/lazy.nvim".source = pkgs.vimPlugins.lazy-nvim;

  # These must also be available in the terminal, outside Neovim's wrapper.
  home.packages = [ pkgs.ripgrep pkgs.fd ];

  # Both examples are terminal-only; copying stays in tmux's paste buffer.
  ijs.tmux.waylandClipboard.enable = false;
  home.stateVersion = "26.05";
}
