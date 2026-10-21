# Hyprland host integration
#
# PURPOSE: Enables the system-level compositor support required by the portable user configuration.
# ROLE: Separate from per-user Hyprland Lua and keybindings.
# CUSTOMIZATION: Review UWSM and XWayland settings before changing session behavior.

{ ... }:
{

programs.hyprland = {
  enable = true;
  withUWSM = true;
  xwayland.enable = true;



  };


}
