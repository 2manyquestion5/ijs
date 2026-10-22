# PURPOSE: Provide a disposable, terminal-only host for the portability example.
# CONSUMER: The development-vm output and its NixOS test; never import on real hardware.
# CUSTOMIZATION: VM resources and guest-only policy belong here; user tools live in home.nix.
# SECURITY: Console autologin is for this local experiment only. The guest has restricted
# networking, no forwarded ports, no admin groups and no shared host directories or store.
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

  networking.hostName = "ijs-development";
  networking.firewall.enable = true;
  services.openssh.enable = false;

  users.users.example.isNormalUser = true;
  services.getty.autologinUser = "example";

  virtualisation = {
    graphics = false;
    memorySize = 2048;
    diskSize = 4096;
    restrictNetwork = true;
    forwardPorts = [ ];

    # Copy the guest's store closure into an image instead of exporting the host store.
    useNixStoreImage = true;
    mountHostNixStore = false;
    # qemu-vm normally adds writable exchange folders, even without user selections.
    sharedDirectories = lib.mkForce { };
  };

  system.stateVersion = "26.05";
}
