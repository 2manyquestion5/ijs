
# =============================================================================
# PORTABLE CONFIGURATION TRANSLATOR
# =============================================================================
#
# This is the public entry point for the translation library.
#
# Consumers ask for a target:
#
#   translator.for "hyprland"
#   translator.for "niri"
#
# The translator returns:
#
#   {
#     bindings = "...";
#     input = "...";
#   }
#
# Consumers receive resolved preferences and do not need their paths
# or how their configuration language is generated.
#
# To support a new program:
#   1. Write an adapter in adapters/.
#   2. Register the adapter below.
#   3. Leave existing adapters and user preferences unchanged.
#
# =============================================================================

{ lib, pkgs, preferences }:

let
  # Preferences are supplied by the user composition, never hardcoded.

  # Shared validation and translation helpers.
  translate = import ./translate.nix {
    inherit lib;
  };

  # Registry of supported configuration targets.
  adapters = {
    hyprland = import ./adapters/hyprland.nix;
    niri = import ./adapters/niri.nix;
  };

in
{
  # Public API.
  #
  # Example:
  #   shared = translator.for "hyprland";
  #
  # Fails clearly if the target is not registered.

  for = target:
    if !builtins.hasAttr target adapters then
      throw "Translator: unsupported target '${target}'"
    else
      adapters.${target} {
        inherit lib pkgs preferences translate;
      };

  # Useful for future tests and module discovery.
  supported = builtins.attrNames adapters;
}
