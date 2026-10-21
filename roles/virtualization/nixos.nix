# PURPOSE: Enable the VM host capability; no default guest starts here.
{ ... }: { imports = [ ../../features/virtualization/nixos.nix ]; }
