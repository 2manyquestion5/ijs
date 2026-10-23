# Niri host integration
#
# PURPOSE: Makes the Niri session available at the OS level.
# ROLE: The user-level Niri configuration lives under infrastructure/modules/home/desktop/niri.
# CUSTOMIZATION: Keep until both compositor sessions have been retested.

{ ... }:
{

  #Enable Niri Wayland compositor
  programs.niri.enable = true;



}
