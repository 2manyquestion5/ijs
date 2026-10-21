# DISCOVERY RULE: exporting modules creates no machine-level permissions.
# Only modules selected by an actual host or role can enable services.
# PURPOSE: Publish feature implementations without enabling them.
# Roles and hosts choose imports; no automatic capability activation.
{ ... }: {
  flake.modules.nixos.virtualization = ../../features/virtualization/nixos.nix;
  flake.modules.nixos.input = ../../features/input/nixos.nix;
  flake.modules.nixos.workstation = ../../roles/workstation/nixos.nix;
  flake.modules.nixos.lab-server = ../../roles/lab-server/nixos.nix;
  flake.modules.homeManager.vm-tools = ../../features/virtualization/home.nix;
}
