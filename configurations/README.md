# Public configuration examples

`infrastructure/` implements reusable capabilities. This directory shows how an
installation selects them using ordinary NixOS and Home Manager modules. The
examples are independent of any maintainer's private configuration.

| Configuration | Purpose | Public build output |
|---|---|---|
| [Default user](users/default/default.nix) | Minimal Hyprland + Waybar desktop user environment | `homeConfigurations.example.activationPackage` |
| [Terminal user](users/terminal/default.nix) | Shared Git, LazyVim, tmux, ripgrep and fd selection | `homeConfigurations.portability.activationPackage` |
| [Development VM](hosts/development-vm/default.nix) | Disposable terminal host using that same user through integrated Home Manager | `nixosConfigurations.development-vm.config.system.build.vm` |
| [Physical-host template](hosts/example/README.md) | Copy and supply your own hardware, boot and authentication choices | None; incomplete by design |

The [portability guide](../examples/portability/README.md) provides standalone,
integrated Home Manager and VM build/test commands. The [root README](../README.md)
builds the desktop user example. Building either user's activation package does
not create an operating-system account or authorize activation on your account.

## Start your own configuration

Follow the [physical-host template guide](hosts/example/README.md) to create a
small consuming flake. Copy configurations you intend to own, then import the
public ijs module interfaces for reusable implementation. You do not need to
copy `infrastructure/`, fork ijs or access anyone's private repository.

Keep actual hardware, accounts, application selections and preferences in your
own repository, which can be private. Public defaults are illustrative choices,
not disclosures of a maintainer's actual installation. Credentials, private
keys and recovery material require separate secure handling; a private Git
repository and the Nix store are not secret vaults.

There is no automatic discovery of private files or fallback to a different user.
The consuming flake explicitly selects its host and user modules. Multiple hosts
can import the same user module, and each host can configure multiple users.
See [architecture](../docs/architecture.md) and [contracts](../docs/contracts.md)
for ownership and supported interfaces.
