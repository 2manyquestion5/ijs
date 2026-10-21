# PURPOSE:
# Provide the standard ijs user environment.
#
# SECURITY:
# This Home Manager module does not create system accounts
# or authorize privileged groups.
#
# CUSTOMIZATION:
# Hosts supply the account identity. Users can replace
# preferences and select different desktop modules.
#
# DEFAULT:
# Hyprland + Waybar with a minimal application collection.

{ pkgs, lib, ijs, ... }:

let
  preferences = ijs.ijs.loadPreferences {
    inherit pkgs;
    directory = ./preferences;
  };

  theme = (ijs.ijs.resolveTheme { inherit lib; })
    preferences.appearance.theme;

  modules = ijs.modules.homeManager;

in {
  _module.args = {
    inherit preferences theme;
  };

  imports = [
    modules.desktop-basics
    modules.lazyvim
    modules.tmux
    modules.hyprland
    modules.waybar
  ];

  home = {
    username = "example";
    homeDirectory = "/home/example";
    stateVersion = "26.05";
  };
}
