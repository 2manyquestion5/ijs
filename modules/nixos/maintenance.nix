# Host maintenance tools
#
# PURPOSE:
#   Provides a small collection of tools for maintaining and
#   repairing a NixOS host.
#
# WHY IT EXISTS:
#   These tools should remain available even when Home Manager,
#   a graphical desktop, or an individual user's configuration
#   is unavailable.
#
# USED BY:
#   Hosts that explicitly import this maintenance capability.
#
# CUSTOMIZATION:
#   Keep this list small. Personal applications belong in
#   Home Manager, not in the system-wide environment.
#
# SECURITY:
#   These tools are available to local users, but installing
#   them does not grant administrative privileges.

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Lightweight terminal editor for repairing configuration.
    vim

    # Retrieve, inspect, and restore configuration repositories.
    git

    # Download files and troubleshoot HTTP connections.
    curl
  ];
}
