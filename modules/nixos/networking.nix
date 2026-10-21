# PURPOSE: Reusable minimal network and firewall baseline.
# SECURITY: Do not open ports or disable reverse path filtering without a
# documented host-specific reason. Services can contribute their own rules.
{ lib, ... }: {
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.checkReversePath = true;
  services.openssh.enable = false;
  # GNOME would otherwise enable mDNS discovery on this workstation.
  services.avahi.enable = lib.mkForce false;
}
