# PURPOSE: Demonstrate declared compatibility checks, not runtime provisioning.
# ROLE/CUSTOMIZATION: Run from the repository root; edit request/host below to experiment.
# SECURITY: --impure permits local source access; use trusted source. No activation occurs.
# Uses nixpkgs from this checkout's pinned flake. See docs/session-negotiation.md.
# Run: nix --extra-experimental-features 'nix-command flakes' eval --impure --json --expr 'import ./examples/negotiation.nix'
let
  flake = builtins.getFlake (toString ../.);
  negotiate = import ../lib/negotiation { lib = flake.inputs.nixpkgs.lib; };
in negotiate {
  request = { allowedModes = [ "vm" "terminal" ]; minMemoryMiB = 16384; forbidNonfreeHost = true; };
  host = { supportedModes = [ "native" "terminal" ]; freeMemoryMiB = 8192; requiresNonfree = false; };
}
