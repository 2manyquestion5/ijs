# ijs

**Portable Nix infrastructure.**

*Your system, your scoops.*

ijs is an open-source project for building reproducible computing environments using NixOS and Home Manager.

It provides reusable system modules, desktop configurations, host roles, user preferences and configuration interfaces. The goal is to make a computing environment portable without taking control away from the host administrator or the individual user.

## Project structure

```text
ijs/
├── configurations/    # Public starter configurations
├── modules/           # Reusable NixOS and Home Manager modules
├── features/          # Optional capabilities
├── roles/             # Workstation and server responsibilities
├── profiles/          # User profile documentation
├── themes/            # Appearance definitions
├── lib/               # Shared functions and translators
├── examples/          # Architecture examples
├── docs/              # Documentation
├── flake.nix
└── AGENTS.md
```

The reusable implementation is collectively called **infrastructure**. Its directories remain at the repository root for now.

The `configurations/` directory contains public starting points. An installation's real hosts, accounts and preferences can be maintained in a separate repository.

## Current starter environment

The first public user example provides:

- Hyprland and Waybar
- Firefox, Foot, Fuzzel and Dolphin
- LazyVim, Git and tmux
- Shared keyboard shortcuts and application actions
- A selectable theme
- Basic desktop utilities

These are defaults, not compulsory dependencies. A headless server can select only the system functionality it requires.

Niri is also available as an optional desktop module.

## Building the example

On a compatible Nix-enabled x86_64 Linux system with flakes available:

```bash
nix build --no-link \
  .#homeConfigurations.example.activationPackage
```

This builds the example Home Manager environment without activating it.

The example uses the illustrative account `example`. It does not create a Linux user, configure disks, or provide a complete operating-system installation.

**Do not activate the example unchanged on your personal account.**

## Personal configurations

Actual hardware settings and individual user choices should be kept separately from the public infrastructure.

A personal configuration can declare a flake dependency on ijs and use its exported modules and helper functions.

For example, a personal repository might contain:

```text
ijs-personal/
├── flake.nix
├── hosts/
│   └── my-host/
└── users/
    └── my-user/
```

The repository name and filesystem location are not part of the public interface.

## Security and privacy

- Host administrators control account creation, permissions, networking and privileged services.
- User preferences do not automatically grant system privileges.
- Registering a module does not activate it.
- Keep passwords, access tokens, private keys and recovery material outside plaintext Git and ordinary Nix configuration values.
- Keep installation-specific identifiers and sensitive local information out of the public repository.
- Treat private repositories as version-controlled configuration, not as secret vaults.
- Evaluate and build changes before activating them on real hardware.

Nix store paths and build artifacts should not be assumed to be confidential.

## Current implementation and roadmap

**Implemented and build-tested:**

- Public NixOS and Home Manager module exports
- Preference loading and theme resolution
- Hyprland and Niri configuration translators
- A buildable Hyprland + Waybar Home Manager example
- Composition of a separately maintained host and user configuration

**Planned or experimental:**

- A fully branded ijs desktop and boot experience
- Niri + Noctalia integration
- A reproducible VM demonstration
- Host/user session negotiation and isolation policies
- Application selection and provisioning improvements
- Broader compatibility and automated testing

Successful builds do not establish that every desktop or hardware configuration has been tested at runtime.

## Documentation and contributing

Start with [the glossary](docs/glossary.md), [architecture](docs/architecture.md), and [configuration contracts](docs/contracts.md).

The [contributor guidelines](AGENTS.md) describe our documentation, modularity, security and testing standards.

Reusable improvements belong in the public project. Individual deployment choices belong in the consuming configuration.

Our goal is to let ijs grow through contributions without sacrificing reproducibility, portability or user control.
