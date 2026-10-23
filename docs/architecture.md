# ijs — Architecture

## Purpose

ijs uses NixOS, Home Manager and flakes to compose system and user configurations.
Its longer-term goal is a computing environment in which users, hosts, profiles,
workspaces, applications, data and networks can be combined with explicit choices
about sharing, isolation, persistence and access.

The current implementation provides reusable modules, preference and theme
helpers, desktop adapters and a Home Manager starter. It does not yet implement
a general workspace, identity or distributed deployment system.

The central design principle is **separation of responsibility**: infrastructure implements capabilities, hosts authorize them, and users select their own preferences.

A complete desktop is one possible composition, not a requirement. Consumers can
select non-graphical modules independently; the lab-server role is currently a
placeholder, not a ready-made server configuration.

For a first build, use the [README](../README.md). The [roadmap](roadmap.md)
records release preparation and validation evidence; this document explains the
design and its boundaries.

## Repository architecture

The project separates public infrastructure from installation-specific configuration.

### Public repository — `ijs`

```text
ijs/
├── infrastructure/
│   ├── modules/               # NixOS, Home Manager and flake composition
│   ├── features/              # Optional capability implementations
│   ├── roles/                 # Host-side capability bundles
│   ├── lib/                   # Translators, helpers and resolution logic
│   └── themes/                # Reusable appearance definitions
├── configurations/
│   ├── users/default/         # Buildable desktop Home Manager example
│   ├── users/terminal/        # User environment shared by both HM modes
│   ├── hosts/development-vm/  # Buildable disposable terminal VM
│   └── hosts/example/         # Physical-host template; requires machine settings
├── profiles/                  # User-profile concepts and documentation
├── examples/                  # Experiment guides and negotiation example
├── tests/                     # Application and VM regression tests
├── docs/
├── flake.nix
└── README.md
```

`infrastructure/` owns reusable implementation, including application packaging
and compatibility handling. `configurations/` selects that implementation using
ordinary NixOS and Home Manager modules. There is no configuration generator or
additional profile language.

The [configuration guide](../configurations/README.md) distinguishes buildable
examples from the incomplete physical-host template. These are generic public
selections, not copies of a maintainer's private configuration.

### Installation-specific repository

A separate repository can compose actual hosts and reusable user configurations
using the public ijs flake. The following layout is illustrative, not required:

```text
ijs-personal/
├── flake.nix
├── hosts/
│   └── my-host/
│       ├── default.nix
│       ├── hardware.nix
│       ├── storage.nix
│       ├── boot.nix
│       └── network.nix
└── users/
    └── my-user/
        ├── default.nix
        └── preferences/
```

This repository can be private or published voluntarily after appropriate review.

Actual secrets must remain outside plaintext Git and ordinary Nix configuration values, including in private repositories.

The consuming flake declares ijs as an input and selects its exported modules
and helper functions. It does not need to copy public implementations.
The [host template guide](../configurations/hosts/example/README.md) shows a
minimal consumer whose configuration files it owns while following ijs's pinned
Nixpkgs and Home Manager inputs. The public project never needs a reference to
that consumer's private repository.

No reusable module should depend on a specific personal repository name, hostname, username, or source directory.

## Objects and ownership

| Object | Responsibility | Boundary |
|---|---|---|
| Host | Hardware, boot, storage, network, account creation and administrative permissions | Does not dictate every user preference |
| User | Applications, input preferences, appearance and personal requirements | Cannot grant privileged host capabilities |
| Feature | Implements an individual capability | Exporting it is inert; importing it can enable functionality |
| Role | Selects related host-side capabilities | Does not own personal application choices |
| Profile | Groups user-side preferences or functionality | Does not grant system permissions |
| Theme | Defines reusable appearance values | Does not control host security |
| Adapter | Translates shared preferences into native program configuration | Must not import a specific user's files |
| Workload | Describes an application or service and its resource needs | Does not own the underlying host |
| Policy | Describes requirements and constraints | Must distinguish enforced rules from proposed checks |

Hosts, users, features, roles, themes and adapters currently use ordinary Nix
composition. Profiles describe user selections; there is no general profile
selection framework. Workloads and policies are design vocabulary, not a runtime
scheduler or an enforcement engine.

The host retains authority over privileged operations. A user configuration can
select applications and user services, but importing a Home Manager module does
not authorize privileged host operations.

## Public module interfaces

ijs uses flake-parts to publish reusable modules through its `flake.modules` registry.

Examples include:

```nix
inputs.ijs.modules.nixos.workstation
inputs.ijs.modules.nixos.virtualization

inputs.ijs.modules.homeManager.hyprland
inputs.ijs.modules.homeManager.waybar
```

Exporting a module makes it available to consumers. It does not activate services, install programs, open firewall ports, or grant administrative privileges on its own.

The consuming configuration selects modules in its NixOS or Home Manager
`imports`. Their declarations can enable packages and services in the generated
configuration. Evaluation resolves those declarations, building prepares the
artifacts, and activation applies them; these are separate steps.

These examples assume the public flake is named `ijs` in the consuming flake's inputs.
The `modules.nixos.*`, `modules.homeManager.*` and `ijs.*` interfaces, existing
Home Manager outputs and `development-vm` output are preserved by the directory
reorganization. Direct imports from the former root implementation paths need
updating; use exported modules rather than depending on that internal layout.
See [technical contracts](contracts.md) for the helper signatures and composition
examples. NixOS, Home Manager and flake-parts modules have different contexts and
are not interchangeable.

## User preferences and desktop adapters

User preferences are defined independently of a desktop environment.

The current preference system separates:

- `applications.nix` — applications associated with semantic actions
- `bindings.nix` — keyboard shortcuts associated with actions
- `input.nix` — pointer, keyboard and interaction preferences
- `appearance.nix` — theme selection

The preference loader resolves these files into a shared value. Desktop adapters then translate that value into native configuration.

This allows supported preferences to be reused across desktop adapters without
copying every shortcut or application setting. It is not a universal desktop API.

The current implementation includes Hyprland and Niri translators.

**Hyprland + Waybar is the public starter for v0.1 preparation.** Niri is
experimental and available separately; Noctalia integration is planned. Adapter
availability does not establish runtime coverage.

## Themes

Themes supply reusable colors and semantic appearance values.

The default public example selects `mocha-purple` through its appearance preferences.

The theme resolver supplies the selected theme to desktop modules, rather than having those modules read a particular user's configuration.

Future ijs-specific branding, boot presentation and theme alternatives should use the same separation between definitions and selections.

## Composition and activation

For the currently implemented static configuration model:

1. A flake declares its dependencies, including ijs.
2. The consuming configuration selects a host and its NixOS modules.
3. An authorized host configuration declares accounts and privileged capabilities.
4. A Home Manager configuration selects user modules and supplies preferences.
5. Shared translators generate program-native settings.
6. Nix evaluates and builds the selected configuration.
7. The operator explicitly activates the system or home environment with the
   permissions appropriate to that configuration.

Building a configuration does not automatically install or activate it.

Runtime user provisioning, resource negotiation, and deployment orchestration are not implied by this process.

The public output `homeConfigurations.example` builds only the user environment.
It does not supply a NixOS host configuration. A consumer selecting the Hyprland
desktop must also configure the host session and locking support. The existing
NixOS integration uses UWSM for session lifecycle, NixOS-managed Hypridle and
Hyprlock's PAM integration; building the Home Manager starter alone does not
configure those host services.

## Portability and privacy

A portable user configuration should not require a particular computer's storage identifiers, network setup, or privileged groups.

A host can support multiple user configurations, while a user configuration can be reused across compatible hosts.

Portability does not automatically imply secure isolation. Ordinary Unix user separation, a native desktop session, and a VM-backed environment provide different security properties.

Machine-specific configuration may be maintained in private Git repositories. Actual credentials require appropriate secret-management mechanisms.

Nix store contents and build outputs must not be assumed confidential.

## Longer-term direction

One user may want the same shell and editor on a laptop, development VM and
server, while keeping different data and permissions on each. Reusing preferences
does not authenticate that user, distribute credentials, synchronize a home
directory or move running processes. Each needs an explicit mechanism.

A workspace would describe related tasks, processes and tools. Data choices
would describe what persists, is synchronized or is withheld; network choices
would describe which services may communicate. These are questions to resolve
through concrete examples, not new framework layers already present in ijs.

Environments may be deliberately open, isolated or partially connected. A
workspace label or Nix option is not a security boundary. Isolation claims must
identify the actual mechanism, trust assumptions and tests. Prefer existing
Linux, NixOS, Home Manager, SSH and virtualization facilities before adding custom
infrastructure.

The existing virtualization modules provide host capabilities. The separate
development VM is a concrete QEMU example, not a general guest-provisioning
system. The negotiation example is a pure compatibility prototype
over declared inputs, not runtime resource allocation, authentication or policy
enforcement. See the [session negotiation design](session-negotiation.md) for its
experimental scope.

Further VM, selective-sharing and multi-host work should follow demonstrated
needs. There is no promise of seamless cross-host login, live process migration,
a secure remote GUI or a cloud control plane. The [roadmap](roadmap.md) separates
near-term release gates from exploration.
