# PURPOSE: Client-side virtual-machine administration convenience.
# Does not grant libvirt permission; host policy controls that separately.
{ ... }: { home.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system"; }
