# Hyprland host integration
#
# PURPOSE: Enables the system-level compositor support required by the portable user configuration.
# ROLE: Separate from per-user Hyprland Lua and keybindings.
# CUSTOMIZATION: Review UWSM and XWayland settings before changing session behavior.
# SECURITY: Hosts selecting this module enable lock authentication and idle startup.

{ ... }:
{

programs.hyprland = {
  enable = true;
  withUWSM = true;
  xwayland.enable = true;



  };

  # NixOS provides PAM and the Hypridle user service through this integration.
  # Home Manager supplies configuration files, not a second idle service.
  programs.hyprlock.enable = true;

}
