# PURPOSE:
# Provide the essential applications for the standard ijs desktop.
#
# SECURITY:
# These are user applications, not system-level services.
# Host permissions and hardware configuration remain separate.
#
# CUSTOMIZATION:
# This is a starter selection, not a mandatory package list.
# Other profiles can import different packages or omit the desktop.
#
# NOTE:
# Keep the executable choices consistent with the standard user's
# preferences/applications.nix and keyboard shortcuts.

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Applications
    firefox                 # Web browser
    foot                    # Terminal
    fuzzel                  # Application launcher
    kdePackages.dolphin     # File manager

        # Development basics
    git
    # Neovim is provided by the LazyVim Home Manager module.
    # tmux is configured by its dedicated Home Manager module.

    # Wayland utilities
    wl-clipboard
    libnotify
    grim
    slurp
    waybar
    swaynotificationcenter
    playerctl               # Media playback controls
    cliphist                # Clipboard history
    wireplumber             # Audio controls through wpctl

    # Session and desktop tools
    hyprlock
    hypridle
    brightnessctl

    # Connectivity interfaces
    networkmanagerapplet
    blueman
  ];
}
