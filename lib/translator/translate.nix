# Shared preference translation helpers
#
# PURPOSE: Converts portable preference vocabulary into adapter-friendly values.
# ROLE: Both desktop adapters depend on this normalization layer.
# CUSTOMIZATION: Keep it independent of specific users and host file paths.

# =============================================================================
# SHARED TRANSLATION HELPERS
# =============================================================================
#
# This file contains operations shared by all adapters.
#
# It does not know anything about Lua, KDL, Hyprland or Niri.
#
# Its responsibilities:
#   - Flatten grouped user shortcuts.
#   - Normalize shortcut names.
#   - Detect duplicate bindings.
#   - Validate shortcut values.
#   - Insert generated code into native configuration templates.
#
# Program-specific syntax belongs in adapters/.
#
# =============================================================================

{ lib }:

let
  # Convert grouped bindings into a uniform list.
  #
  # Example:
  #   windows.close = "SUPER+Q";
  #
  # Result:
  #   {
  #     category = "windows";
  #     action = "close";
  #     key = "SUPER+Q";
  #   }

  flatten = bindings:
    lib.concatLists (
      lib.mapAttrsToList (category: actions:
        lib.mapAttrsToList (action: key: {
          inherit category action key;
        }) actions
      ) bindings
    );

  # Normalize case and spaces for comparison.
  normalize = key:
    lib.toUpper (
      lib.replaceStrings [ " " ] [ "" ] key
    );

  # Find all duplicate shortcut combinations.
  duplicates = entries:
    let
      keys = map (entry: normalize entry.key) entries;
    in
      lib.unique (
        lib.filter
          (key:
            lib.length (lib.filter (x: x == key) keys) > 1
          )
          keys
      );

in
{
  inherit flatten normalize;

  # Validate the user's binding specification.
  #
  # A duplicate or invalid shortcut is an error.
  # It must not silently overwrite another binding.

  validateBindings = bindings:
    let
      entries = flatten bindings;

      invalid = lib.filter
        (entry:
          !builtins.isString entry.key
          || entry.key == ""
        )
        entries;

      # Check types before normalizing.
      repeated =
        if invalid != [] then []
        else duplicates entries;

    in
      if invalid != [] then
        throw "Translator: shortcuts must be non-empty strings."
      else if repeated != [] then
        throw (
          "Translator: duplicate shortcuts: "
          + lib.concatStringsSep ", " repeated
        )
      else
        entries;

  # Insert generated code into a documented native template.
  #
  # A missing or duplicated marker is an error.

  insert = marker: generated: template:
    let
      count =
        lib.length (lib.splitString marker template) - 1;
    in
      if count != 1 then
        throw "Translator: expected exactly one marker '${marker}'"
      else
        lib.replaceStrings
          [ marker ]
          [ generated ]
          template;
}
