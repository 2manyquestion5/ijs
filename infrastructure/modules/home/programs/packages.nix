# Personal application packages
#
# PURPOSE:
#   Provides the applications used by this user's environment.
#
# WHY IT EXISTS:
#   Personal software belongs to the user configuration rather than
#   being permanently tied to one physical host.
#
# ORGANIZATION:
#   Packages are grouped by purpose for readability.
#   Future preference resolution will select interchangeable
#   applications without installing every alternative.
#
# SECURITY:
#   Package selection must eventually respect both user requirements
#   and host software policies.
#
# CUSTOMIZATION:
#   Add applications to the appropriate category below.
#   Host maintenance tools belong in infrastructure/modules/nixos/maintenance.nix.
#
# NOTE:
#   This V1 list is installed eagerly by Home Manager.
#   On-demand application provisioning is not implemented yet.
{ pkgs, ... }:
{
  programs.gh = {
    enable = true;
    # Install the CLI without changing Git's existing credential helpers.
    gitCredentialHelper.enable = false;
  };

  # Keep Yazi's default behavior; Home Manager owns its installation.
  programs.yazi.enable = true;

  home.packages = with pkgs; [
    # WEB BROWSERS
    # Firefox is the currently selected browser.
    # Alternative browsers will eventually be handled by user preferences.
    firefox

    # TERMINAL / FILE MANAGEMENT
    foot                    # Wayland terminal
    kdePackages.dolphin     # GUI file manager
    fuzzel                  # Application launcher

    # SHELL / DEVELOPMENT / SOURCE CONTROL
    git                     # Version control
    lazygit                 # Terminal Git interface
    tree                    # Directory tree
    ripgrep                 # Fast recursive text search
    fd                      # File finder
    jq                      # JSON processing
    bat                     # File viewer with syntax highlighting
    statix                  # Nix static analysis

    # ARCHIVE TOOLS
    zip                     # Create ZIP archives
    unzip                   # Extract ZIP archives
    _7zz                    # Modern 7zip CLI (7zz)

    # WAYLAND DESKTOP UTILITIES
    wl-clipboard            # Wayland clipboard interface
    libnotify               # Desktop notifications client
    grim                    # Screenshots
    slurp                   # Select screenshot region
    waybar                  # Status bar
    swaynotificationcenter  # Notification center
    brightnessctl           # Screen brightness utility

    # DESKTOP SESSION / LOCK
    hyprlock                # Screen lock (Hyprland-compatible)
    hypridle                # Idle management

    # CONNECTIVITY CLIENTS (do not enable host services)
    networkmanagerapplet    # NetworkManager tray UI
    blueman                 # Bluetooth management UI
    wireguard-tools         # VPN command-line utilities
    proton-vpn              # VPN client application

    # CREATIVE AND NOTES
    gimp                    # Image editing
    obsidian                # Notes; review proprietary license policy
  ];
}
