
# =============================================================================
# NIRI — HOME MANAGER ENTRY POINT
# =============================================================================
#
# Shared configuration is requested through translator/default.nix.
#
# Niri consumes generated KDL rather than Hyprland Lua.
# The translator handles this distinction.
#
# This module assembles and installs the resulting configuration.
#
# =============================================================================

{ lib, pkgs, preferences, ... }:

let
  translator = import ../../../../lib/translator {
    inherit lib pkgs preferences;
  };

  shared = translator.for "niri";

  helpers = import ../../../../lib/translator/translate.nix {
    inherit lib;
  };

  bindingsKdl = helpers.insert
    "// @SHARED_BINDINGS@"
    shared.bindings
    (builtins.readFile ./bindings.kdl);

  inputKdl = helpers.insert
    "// @SHARED_INPUT@"
    shared.input
    (builtins.readFile ./input.kdl);

in
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  xdg.configFile."niri/bindings.kdl".text = bindingsKdl;

  xdg.configFile."niri/input.kdl".text = inputKdl;
}
