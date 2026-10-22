
# ijs — Glossary

<!--
PURPOSE:
  Explain the technologies and architectural terms used in this project.

WHY IT EXISTS:
  Some names belong to the Nix ecosystem, while others describe concepts
  we are designing ourselves. Distinguishing them makes the project easier
  to understand, maintain, and extend.

MAINTENANCE:
  Add new terminology when introducing a significant concept.
  Keep explanations short and link to detailed documentation when needed.
-->

## 1. Nix ecosystem

These are established technologies, not concepts invented by this project.

| Term | Meaning |
|---|---|
| **Nix** | Package manager and functional configuration language used to describe reproducible software environments. |
| **NixOS** | Linux distribution whose operating system configuration is managed declaratively using Nix. |
| **Nixpkgs** | Collection of software packages and NixOS modules maintained by the Nix community. |
| **Nix store** | Location, normally `/nix/store`, where Nix stores built packages and dependencies. |
| **Derivation** | Build specification that tells Nix how to produce an output. |
| **Flake** | Standardized interface for declaring Nix dependencies and outputs. |
| **flake.nix** | File defining a flake's inputs and outputs. |
| **flake.lock** | File pinning dependency versions for reproducibility. |
| **flake-parts** | Framework used to organize flake definitions into composable modules. |
| **NixOS module** | Configuration component contributing options to a NixOS system. |
| **Home Manager** | Tool for managing a user's applications, dotfiles, and settings declaratively. |
| **Home Manager module** | Configuration component contributing options to a user's Home Manager environment. |
| **Generation** | Previous or current version of a Nix-managed environment, allowing rollback where supported. |

## 2. Project architecture

These terms describe the current composition model and longer-term design.
Their presence here does not mean a corresponding runtime API exists. See
[architecture](architecture.md) for ownership and [the roadmap](roadmap.md) for
implementation and validation status.

| Term | Meaning |
|---|---|
| **Host** | Physical machine or VM providing computing resources and enforcing administrative policy. |
| **User** | Account or person whose configuration selects preferences and applications. Reusing configuration does not authenticate that user on another host. |
| **Capability** | Function a host or environment can provide, such as virtualization or graphical sessions. |
| **Feature** | Reusable implementation of a capability. Defining a feature does not automatically enable it. |
| **Role** | Host-side composition of NixOS capabilities; the workstation role is implemented, while lab-server is a placeholder. |
| **Profile** | User-side grouping of applications and preferences; currently a concept, not a complete selection system. |
| **Preference** | Desired behavior that may permit acceptable alternatives. |
| **Requirement** | Mandatory condition that must be satisfied before an environment is accepted. |
| **Policy** | Rules governing security, software, permissions, and resource use. |
| **Workload** | Application, service, or job requiring computing resources. |
| **Compatibility check** | Comparison of declared requirements and capabilities. The current negotiation prototype checks mode overlap, memory and one software-freedom flag; it does not enforce runtime policy. |
| **Session** | Authorized environment in which a user interacts with a host or its resources. |
| **Session provisioning** | Future runtime process for allocating resources and launching a negotiated session. |
| **Native session** | Environment using the host's existing operating system infrastructure. |
| **Isolated session** | Environment with a stated isolation mechanism and trust assumptions, potentially using a VM. Not implemented as a general ijs session service. |
| **Workspace** | Grouping of related activity. A Hyprland workspace organizes windows; the broader ijs workspace concept is exploratory and does not itself enforce isolation. |
| **Portable environment** | User configuration that can be reproduced on different compatible hosts. |
| **Persistence** | Preservation of personal files or application state across sessions. |

## 3. Virtualization and infrastructure

| Term | Meaning |
|---|---|
| **KVM** | Linux kernel virtualization technology used for hardware-assisted virtual machines. |
| **QEMU** | Machine emulator and virtualizer commonly used with KVM. |
| **libvirt** | Management system for virtual machines and related virtualization resources. |
| **Virtual machine (VM)** | Isolated guest computer running its own operating system. |
| **Guest** | Operating system running inside a VM. |
| **Hypervisor** | Software responsible for running and managing virtual machines. |
| **Container** | Process-level isolation environment sharing the host kernel. |
| **Headless server** | Computer running without a graphical desktop session. |
| **SSH** | Protocol for encrypted remote access and administration. |
| **LUKS** | Linux disk-encryption format used to protect storage devices. |
| **EFI / UEFI** | Firmware interface used to start modern computers. |

## 4. Repository conventions

| Term | Meaning |
|---|---|
| **modules/** | Reusable Nix configuration implementations. |
| **hosts/** | Machine-specific compositions and hardware configurations. |
| **users/** | Personal account definitions, preferences, and requirements. |
| **roles/** | Host-oriented capability selections. |
| **profiles/** | Documentation of planned user-side selections; no general profile-selection implementation yet. |
| **themes/** | Reusable appearance definitions and palettes. |
| **lib/** | Shared functions, translators, and helpers. |
| **docs/** | Architecture, installation, security, and contributor documentation. |
| **AGENTS.md** | Instructions and conventions for coding assistants and contributors. |
| **CONTRIBUTING.md** | Practical development, validation and publication workflow. |

## 5. Important distinctions

### NixOS vs. Home Manager

NixOS configures the host operating system.

Home Manager configures an individual user's environment.

A single flake can expose both.

### Feature vs. role

A feature defines a reusable implementation.

A role selects and combines features for a particular purpose.

Exporting a module makes it available. Importing/selecting it contributes
configuration and can enable services in the resulting configuration. Activation
applies that configuration to a running environment; building does not activate
it. Host-level declarations remain responsible for privileged capabilities.

### Preference vs. requirement

A preference allows acceptable alternatives.

A requirement is mandatory. A future compatibility interface must reject an
unsatisfied requirement rather than silently weakening it. The current
prototype checks only a small set of declared conditions, not every possible
requirement or host claim.

### Configuration vs. personal data

Configuration describes how an environment should be constructed.

Personal data includes files, credentials, browser state, and other mutable information.

The current configuration model does not transfer or synchronize personal data.
Selective data sharing and persistence across hosts are future work, not
properties supplied automatically by a reusable user configuration.

### Build-time vs. runtime

Nix evaluates and builds declarative configurations.

Existing host and application services handle runtime behavior such as login
and locking. General resource negotiation and session provisioning are proposed
ijs capabilities, not services implemented by the current prototype.

A successful NixOS build does not prove that future session provisioning or security enforcement is implemented.
