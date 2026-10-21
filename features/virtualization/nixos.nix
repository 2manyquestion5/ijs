# RESOURCE NOTE: enabling libvirt is not equivalent to allocating a VM.
# Future session resource negotiation and guest lifecycle management are separate.
# PURPOSE: Host-side KVM/libvirt capability for explicitly authorized hosts.
# SECURITY: Membership in libvirtd is a privileged host-owner decision.
{ ... }: {
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
