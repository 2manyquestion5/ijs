# PURPOSE: Resolve a public theme name to a concrete palette.
# New themes must be explicitly registered to avoid accidental activation.
{ lib }: let
  registry = {
    mocha-purple = import ../../themes/mocha-purple/default.nix;
  };
in name: if builtins.hasAttr name registry then registry.${name} else
  throw "Unknown theme '${name}'. Available: ${lib.concatStringsSep ", " (builtins.attrNames registry)}"
