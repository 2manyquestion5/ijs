
# =============================================================================
# HYPRLAND — HOME MANAGER ENTRY POINT
# =============================================================================
#
# Shared configuration comes from translator/default.nix.
# This file only installs the translated Lua and local desktop files.
#
# The native bindings.lua and input.lua are templates containing
# documented insertion markers.
#
# =============================================================================

{ lib, pkgs, preferences, ... }:

let
  translator = import ../../../../lib/translator {
    inherit lib pkgs preferences;
  };

  shared = translator.for "hyprland";

  helpers = import ../../../../lib/translator/translate.nix {
    inherit lib;
  };

  bindingsLua = helpers.insert
    "-- @SHARED_BINDINGS@"
    shared.bindings
    (builtins.readFile ./bindings.lua);

  inputLua = helpers.insert
    "-- @SHARED_INPUT@"
    shared.input
    (builtins.readFile ./input.lua);

in
{
  # Lock and idle settings
  xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
  xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false;

    extraLuaFiles = {
      "bindings.lua" = {
        content = bindingsLua;
        autoLoad = true;
      };

      "input.lua" = {
        content = inputLua;
        autoLoad = true;
      };

      "autostart.lua" = {
        content = ./autostart.lua;
        autoLoad = true;
      };

      "appearance.lua" = {
        content = ./appearance.lua;
        autoLoad = true;
      };
    };
  };
}
