# Run from repository: nix eval --json --expr 'import ./examples/negotiation.nix'
# NOTE: for standalone eval, `nixpkgs` from the pinned flake is required.
let
  flake = builtins.getFlake (toString ../.);
  negotiate = import ../lib/negotiation { lib = flake.inputs.nixpkgs.lib; };
in negotiate {
  request = { allowedModes = [ "vm" "terminal" ]; minMemoryMiB = 16384; forbidNonfreeHost = true; };
  host = { supportedModes = [ "native" "terminal" ]; freeMemoryMiB = 8192; requiresNonfree = false; };
}
