# PURPOSE:
# Export reusable ijs modules and configuration functions.
# Other repositories can consume these without relying on file paths.
#
# SECURITY:
# Exports do not automatically activate programs or grant privileges.
# Hosts and users still explicitly choose what they enable.
#
# PORTABILITY:
# Public interfaces remain independent of hostnames and usernames.
# Personal configuration is supplied by the consuming flake.

{ inputs, ... }: {

  # Public helpers used by independent host and user configurations.
  flake.ijs = {
    loadPreferences = import ../../lib/preferences;
    resolveTheme = import ../../lib/themes;
  };
  # PURPOSE:
  # Export reusable system modules.
  # Hosts explicitly decide which modules to enable.
  flake.modules.nixos = {
    networking = ../../modules/nixos/networking.nix;
    audio = ../../modules/nixos/audio.nix;
    locale = ../../modules/nixos/locale.nix;
    maintenance = ../../modules/nixos/maintenance.nix;
    bluetooth = ../../modules/nixos/bluetooth.nix;
  };
  # Reusable Home Manager modules.
  flake.modules.homeManager = {
    # Desktop environments and interface components.
    niri = ../../modules/home/desktop/niri;
    hyprland = ../../modules/home/desktop/hyprland;
    waybar = ../../modules/home/desktop/waybar;
    desktop-basics = ../../modules/home/programs/desktop-basics.nix;

    # Applications and development environment.
    packages = ../../modules/home/programs/packages.nix;
    # One application import includes its upstream options and ijs defaults.
    lazyvim = {
      imports = [
        inputs.lazyvim.homeManagerModules.default
        ../../modules/home/programs/lazyvim.nix
      ];
    };
    tmux = ../../modules/home/programs/tmux.nix;
  };
}
