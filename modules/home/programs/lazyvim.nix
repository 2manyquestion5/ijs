# LazyVim editor configuration
#
# PURPOSE: Retains the working editor and applies the user-selected color theme.
# ROLE: Imported from the user’s Home Manager configuration.
# CUSTOMIZATION: Language extras are intentionally explicit; modify them only for selected profiles.
# SECURITY: Plugins are supplied by Nix; startup never installs missing plugins.

{ config, lib, pkgs, theme, ... }:

{
  # Upstream compatibility: keep its configuration, correcting only the known
  # bootstrap/path/template defects. An explicit source overrides HM's default
  # file generated from text, without replacing the upstream module itself.
  xdg.configFile."nvim/init.lua".source = pkgs.writeText "ijs-lazyvim-init.lua"
    (import ./lazyvim-init.nix {
      inherit lib pkgs;
      upstreamInit = config.xdg.configFile."nvim/init.lua".text;
    });

  programs.lazyvim = {
    enable = true;

    # Existing ijs selections: retain both language extras and the theme flavour.
    extras = {
      lang.nix.enable = true;
      lang.python.enable = true;
      # Upstream only packages declared extras; LazyVim already defaults to Blink.
      coding.blink.enable = true;
    };
    plugins.colorScheme = ''
      return {
        {
          "catppuccin/nvim",
          name = "catppuccin",
          opts = { flavour = "${theme.catppuccinFlavor}" },
        },
      }
    '';

    # Upstream's manifest omits friendly-snippets. Use Nixpkgs' Blink build,
    # including its native library, rather than compiling/downloading at startup.
    plugins.nixDependencies = ''
      return {
        {
          "saghen/blink.cmp",
          dir = "${pkgs.vimPlugins.blink-cmp}",
          build = false,
          pin = true,
          opts = { fuzzy = { prebuilt_binaries = { download = false } } },
        },
        { "rafamadriz/friendly-snippets", dir = "${pkgs.vimPlugins.friendly-snippets}", pin = true },
      }
    '';
  };
}
