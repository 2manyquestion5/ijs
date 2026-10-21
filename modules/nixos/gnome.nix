# GNOME fallback desktop
#
# PURPOSE: Keeps the existing GDM/GNOME login option while experimenting with Niri and Hyprland.
# ROLE: A workstation role imports this; GNOME may enable additional services.
# CUSTOMIZATION: Remove from the workstation role only after a reliable alternative login is tested.

{ ... }:
{

services = {
  displayManager.gdm.enable = true;
  desktopManager.gnome.enable = true;

  xserver.xkb = {
    layout = "us";
    variant = "";
  };
};

}
