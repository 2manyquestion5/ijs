# PURPOSE: Show how a consuming repository composes an ordinary NixOS workstation.
# CONSUMER: Copy this template and configurations/users/default into your own repository.
# CUSTOMIZATION: Supply hardware, boot and authentication; see the adjacent README.
# SECURITY: No disk layout, credentials, autologin or administrative groups are supplied.
# This template is intentionally not exported as a buildable public host.
{ inputs, ... }:
let
  ijs = inputs.ijs;
in
{
  imports = [
    # Generate this for YOUR machine. It is deliberately absent from public ijs.
    # Review its filesystems, encrypted devices, swap and hardware declarations.
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    ijs.modules.nixos.networking
    # Optional sound support and system-wide recovery tools (Vim, Git and curl).
    ijs.modules.nixos.audio
    ijs.modules.nixos.maintenance
    # This existing role provides GNOME/GDM, Hyprland/UWSM and experimental Niri.
    # Its selection enables host services; it is not just a list of packages.
    ijs.modules.nixos.workstation
  ];

  # Machine identity and host-specific overrides belong here, not in infrastructure.
  networking.hostName = "ijs-example";
  # The networking module enables NetworkManager/firewall and disables SSH.
  # Keep Wi-Fi/VPN credentials outside Nix source and ordinary Nix store values.

  # Select a preferred login session; the other role-provided sessions remain available.
  services.displayManager.defaultSession = "hyprland-uwsm";

  # Supply bootloader/EFI settings for this machine before building or deploying.
  # Reuse reviewed settings for an existing installation. For a new UEFI install,
  # systemd-boot is one option, but its ESP mount and firmware access need review:
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  # Generic example only. If renamed, update both keys below and the copied user's
  # home.username/home.homeDirectory. No working login or admin access is supplied.
  users.users.example.isNormalUser = true;
  # Configure authentication explicitly, for example a securely provisioned runtime
  # hashedPasswordFile. Do not read a secret into Nix or use a default password.
  # Grant administrative groups only through a deliberate host-owner decision.

  # Standard integrated Home Manager: host creates the account; user module selects
  # applications/preferences. The public starter includes only its minimal tools.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit ijs; };
    users.example = import ../../users/default;
  };

  # For a new installation only. Existing systems retain their original stateVersion;
  # it controls compatibility defaults and is not a dependency-update setting.
  system.stateVersion = "26.05";
}
