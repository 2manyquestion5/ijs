# Portable application action choices
#
# PURPOSE: Maps shared actions to concrete application executables and packages.
# ROLE: Consumed by the preference translator; not a system package installation policy.
# CUSTOMIZATION: Replace application selection here, rather than editing every desktop adapter.

# Selected applications for each shared action.
# Package references allow Nix to locate the executables reliably.

{ pkgs }:

{
  apps = {
    package = pkgs.fuzzel;
    executable = "fuzzel";
  };

  terminal = {
    package = pkgs.foot;
    executable = "foot";
  };

  browser = {
    package = pkgs.firefox;
    executable = "firefox";
  };

  files = {
    package = pkgs.kdePackages.dolphin;
    executable = "dolphin";
  };

  wifi = {
    package = pkgs.networkmanagerapplet;
    executable = "nm-connection-editor";
  };

  bluetooth = {
    package = pkgs.blueman;
    executable = "blueman-manager";
  };
}
