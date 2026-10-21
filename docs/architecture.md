# ijs — Architecture

## Purpose

ijs is a portable Nix infrastructure project built around NixOS, Home Manager, and flakes.

It provides reusable components for configuring operating systems, desktop environments, servers, and portable user environments.

The central design principle is **separation of responsibility**: infrastructure implements capabilities, hosts authorize them, and users select their own preferences.

A complete desktop is one possible result, not a requirement. A headless server can use ijs without importing any graphical modules.

## Repository architecture

The project separates public infrastructure from installation-specific configuration.

### Public repository — `ijs`

```text
ijs/
├── configurations/
│   └── users/default/         # Buildable Home Manager starter
├── modules/
│   ├── flake/                 # Public exports and example outputs
│   ├── nixos/                 # Shared system modules
│   └── home/                  # Shared user and desktop modules
├── features/                  # Optional capabilities
├── roles/                     # Host-side capability bundles
├── profiles/                  # User-profile concepts and documentation
├── lib/                       # Translators, helpers and resolution logic
├── themes/                    # Reusable appearance definitions
├── examples/                  # Architecture examples
├── docs/
├── flake.nix
└── README.md
```

The directories `modules/`, `features/`, `roles/`, `lib/`, and `themes/` collectively form ijs's reusable infrastructure.

The public repository also provides starter configurations so contributors can evaluate and build examples without possessing anyone's private machine configuration.

### Installation-specific repository

A separate repository can compose actual hosts and portable users using the public ijs flake.

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

The private flake declares ijs as an input and selects its exported modules and helper functions. It does not need to copy public implementations.

No reusable module should depend on a specific personal repository name, hostname, username, or source directory.

## Objects and ownership

| Object | Responsibility | Boundary |
|---|---|---|
| Host | Hardware, boot, storage, network, account creation and administrative permissions | Does not dictate every user preference |
| User | Applications, input preferences, appearance and personal requirements | Cannot grant privileged host capabilities |
| Feature | Implements an individual capability | Does not automatically activate itself |
| Role | Selects related host-side capabilities | Does not own personal application choices |
| Profile | Groups user-side preferences or functionality | Does not grant system permissions |
| Theme | Defines reusable appearance values | Does not control host security |
| Adapter | Translates shared preferences into native program configuration | Must not import a specific user's files |
| Workload | Describes an application or service and its resource needs | Does not own the underlying host |
| Policy | Describes requirements and constraints | Must distinguish enforced rules from proposed checks |

The host retains authority over privileged operations. A portable user can request capabilities but cannot authorize them simply by importing a Home Manager module.

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

The consuming configuration explicitly selects the modules it needs.

These examples assume the public flake is named `ijs` in the consuming flake's inputs.

## User preferences and desktop adapters

User preferences are defined independently of a desktop environment.

The current preference system separates:

- `applications.nix` — applications associated with semantic actions
- `bindings.nix` — keyboard shortcuts associated with actions
- `input.nix` — pointer, keyboard and interaction preferences
- `appearance.nix` — theme selection

The preference loader resolves these files into a shared value. Desktop adapters then translate that value into native configuration.

This permits the same preference definitions to be reused across different desktop environments without copying every shortcut or application setting.

The current implementation includes Hyprland and Niri translators.

**Hyprland + Waybar is the public v0.1 starter.** Niri is available separately; Noctalia integration is planned.

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
7. The administrator explicitly chooses whether to activate it.

Building a configuration does not automatically install or activate it.

Runtime user provisioning, resource negotiation, and deployment orchestration are not implied by this process.

## Portability and privacy

A portable user configuration should not require a particular computer's storage identifiers, network setup, or privileged groups.

A host can support multiple user configurations, while a user configuration can be reused across compatible hosts.

Portability does not automatically imply secure isolation. Ordinary Unix user separation, a native desktop session, and a VM-backed environment provide different security properties.

Machine-specific configuration may be maintained in private Git repositories. Actual credentials require appropriate secret-management mechanisms.

Nix store contents and build outputs must not be assumed confidential.

## Roles, profiles and workloads

These terms have distinct meanings:

**Role:** A host-side composition, such as a workstation or virtualization host.

**Profile:** A user-side selection of preferences, applications or behaviors.

**Workload:** A requested service or application with associated resource requirements.

A headless server role should not import graphical functionality unless explicitly requested.

Features and roles currently use ordinary Nix module composition. Richer role/profile selection interfaces are planned.

## Roadmap and non-goals for v0.1

The initial public release focuses on reusable modules, a buildable desktop starter, documented interfaces and a separate private configuration workflow.

Future development may include:

- Niri + Noctalia
- A unified ijs desktop theme and boot identity
- A configurable VM demonstration
- Portable user-session negotiation
- Resource and software-policy compatibility checks
- Application selection and controlled on-demand provisioning
- Remote host trust and multi-user deployment

These are development directions, not guarantees of current functionality.

The project should grow through reusable public improvements rather than accumulating incompatible machine-specific forks.

**Guiding rule:** Public ijs owns capabilities and interfaces; installation-specific configurations own selections, identity and authorization.
