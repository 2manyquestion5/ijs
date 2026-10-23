# LazyVim editor configuration
#
# PURPOSE: Retains the working editor and applies the user-selected color theme.
# ROLE: The exported application module includes upstream's Home Manager module.
# CUSTOMIZATION: Override native programs.lazyvim options; enable = false removes
# this integration. Only the default nvim configuration directory is supported.
# SECURITY: Plugins are supplied by Nix; startup never installs missing plugins.

{ config, lib, pkgs, theme, ... }:

{
  # Importing selects LazyVim; an ordinary native assignment can disable it.
  config = lib.mkMerge [
    { programs.lazyvim.enable = lib.mkDefault true; }
    (lib.mkIf config.programs.lazyvim.enable {
      # Upstream compatibility: keep its configuration, correcting only the known
      # bootstrap/path/template defects. An explicit source overrides HM's default
      # file generated from text, without replacing the upstream module itself.
      xdg.configFile."nvim/init.lua".source =
        if config.programs.lazyvim.appName != "nvim" then
          throw "ijs LazyVim supports only programs.lazyvim.appName = \"nvim\"; alternate configuration directories need a separately validated integration."
        else pkgs.writeText "ijs-lazyvim-init.lua"
          (import ./lazyvim-init.nix {
            inherit lib pkgs;
            upstreamInit = config.xdg.configFile."nvim/init.lua".text;
          });

      programs.lazyvim = {
        # Existing ijs selections: retain both language extras and the theme flavour.
        extras = {
          lang.nix.enable = lib.mkDefault true;
          lang.python.enable = lib.mkDefault true;
          # Upstream only packages declared extras; LazyVim already defaults to Blink.
          coding.blink.enable = lib.mkDefault true;
        };
        plugins.colorScheme = lib.mkDefault ''
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
    })
  ];
}
