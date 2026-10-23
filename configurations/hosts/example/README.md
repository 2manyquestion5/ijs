# Physical-host template

[default.nix](default.nix) demonstrates a host importing public ijs capabilities
and connecting an account to the [default user](../../users/default/default.nix)
through Home Manager's standard NixOS module. It is a template for copying,
**not a complete system or a public `nixosConfigurations.example` output**.

The required `hardware-configuration.nix` is intentionally absent. No placeholder
disk identifiers, bootloader, password, autologin or administrative groups are
provided. Use the [development VM](../development-vm/default.nix) and its
[guide](../../../examples/portability/README.md) for an already composed host
that can be built and booted without physical-machine settings.

## Create a consuming repository

The commands below copy only generic public examples. Run them from a public ijs
checkout; choose a new destination that does not already contain configuration:

```bash
mkdir -p ../my-ijs/configurations/hosts/example ../my-ijs/configurations/users
cp configurations/hosts/example/default.nix ../my-ijs/configurations/hosts/example/
cp -R configurations/users/default ../my-ijs/configurations/users/
cd ../my-ijs
```

Create a `flake.nix` in that new directory:

```nix
{
  description = "My ijs configuration";
  inputs = {
    ijs.url = "github:2manyquestion5/ijs";
    nixpkgs.follows = "ijs/nixpkgs";
    home-manager.follows = "ijs/home-manager";
  };
  outputs = inputs: {
    nixosConfigurations.example = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./configurations/hosts/example ];
    };
  };
}
```

The first lock operation resolves ijs and its dependency pins. Review and retain
your own `flake.lock`; later public updates are deliberate input updates, not
automatic changes to your running system. The example currently targets
`x86_64-linux`; other platforms need separate validation.

## Supply machine-specific values

1. **Hardware and storage.** On an existing NixOS machine, inspect its working
   hardware configuration. To write a fresh hardware description into this new
   repository, NixOS provides:

   ```bash
   sudo nixos-generate-config --show-hardware-config \
     > configurations/hosts/example/hardware-configuration.nix
   ```

   This records the running machine's detected hardware and mounts; it does not
   partition disks or replace `/etc/nixos`. Review root/EFI filesystems, LUKS,
   swap and any additional storage settings against the working installation.
   A new installation must instead use its intended mounted target and the
   [NixOS installation procedure](https://nixos.org/manual/nixos/stable/#sec-installation).
   Do not infer a new disk layout from this template.
2. **Boot.** Supply the reviewed bootloader and EFI settings in the host module
   or another explicitly imported host file. Commented systemd-boot lines are an
   illustration, not a choice made for your machine.
3. **Identity and access.** Choose the hostname and account name. If replacing
   `example`, update the NixOS account, Home Manager user key and copied user's
   `home.username`/`home.homeDirectory` together. Configure authentication and
   preserve administrative/recovery access before activation. A runtime
   `users.users.<name>.hashedPasswordFile` is one supported approach, but that
   file needs secure provisioning and permissions; the template does not
   install a secrets manager or supply that file.
4. **Services and applications.** Review each host import. The workstation role
   enables GDM/GNOME, Hyprland/UWSM and experimental Niri; Hyprland is preferred
   here. The networking module enables NetworkManager and the firewall and
   disables SSH. The copied user owns preferences and its minimal application
   selection; the larger public `packages` collection is not selected.
   Audio and maintenance imports are optional capabilities. For a terminal-only
   host, follow the separate VM's composition instead of importing this desktop
   role and user. Integrated Home Manager is this template's choice; the existing
   standalone examples remain supported.
5. **Compatibility and privacy.** Preserve existing NixOS and Home Manager
   `stateVersion` values when adapting an existing installation. Keep actual
   hardware identifiers and personal selections in your consuming repository;
   protect secrets separately. Review publication using the
   [security guide](../../../docs/security-and-publication.md).

If the new directory is a Git repository, Nix flakes include tracked/staged
source files, not arbitrary untracked files. Review and stage intended source
before building. Private hardware configuration can be versioned in your private
repository; keep secret material out of it.

## Build and review

After supplying and reviewing all required settings, from your consuming flake:

```bash
nix --extra-experimental-features 'nix-command flakes' build --no-link \
  .#nixosConfigurations.example.config.system.build.toplevel
```

This builds a system closure; it does not activate it. A successful build does
not validate disk access, login, locking or hardware behavior. Compare the
candidate with the working system, confirm backups/recovery and review any
Home Manager file collisions before planning a separate deployment. This guide
intentionally provides no activation command.
