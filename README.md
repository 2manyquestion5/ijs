# ijs

ijs is a project for building composable computing environments with NixOS,
Home Manager and Nix flakes. It provides reusable system and user modules,
shared desktop preferences and a public example you can build independently.

The longer-term goal is to connect users, hosts, profiles, workspaces,
applications, data and networks with explicit choices about sharing,
persistence, access and isolation. Today's implementation is smaller: static
Nix module composition and a Hyprland + Waybar Home Manager starter.

## What is available today?

- Reusable NixOS and Home Manager modules, plus preference and theme helpers.
- A minimal desktop example with Hyprland, Waybar, Firefox, Foot, Fuzzel,
  Dolphin, Git, LazyVim, tmux and basic desktop utilities.
- Additional application modules that consumers can select separately. The
  starter does **not** import the larger `packages` collection containing
  GitHub CLI, Yazi and archive tools. Tools available inside an application's
  wrapper are not necessarily available in a normal terminal.

**v0.1 is in preparation, not released.** Earlier starter revisions have passed
local builds; several recently repaired desktop components still await live
validation. Niri is experimental. Automated deployment, runtime session
negotiation and cross-host session orchestration are not implemented. See the
[roadmap](docs/roadmap.md) for evidence and remaining milestones.

## Build the public example

You need Git and a working Nix installation on **x86_64 Linux**, internet access
and space for the build dependencies. The command enables Nix's flake features
for this invocation; no permanent Nix settings change is needed.

Run this from a directory where you want a new `ijs` checkout:

```bash
git clone https://github.com/2manyquestion5/ijs.git
cd ijs
nix --extra-experimental-features 'nix-command flakes' build \
  --no-link --no-write-lock-file \
  .#homeConfigurations.example.activationPackage
```

This builds the Home Manager example using the checked-in dependency lockfile.
It does not activate it, change the running desktop, or create a `result`
symlink. The first build can download and build many dependencies.

The example targets the illustrative account `example` at `/home/example`.
It is **not a complete NixOS installer or a ready-to-activate workstation**:
it does not create accounts, configure disks or provide the host's graphical
session and PAM integration. **Do not activate it unchanged on your account.**

## Use modules in your own configuration

Public ijs owns reusable functionality and examples. A separate consuming
repository owns actual hosts, accounts, hardware settings and user selections;
it can be private. It declares ijs as a flake input and imports the modules it
needs. Exporting a module only makes it available. Importing it contributes
configuration; evaluation and building prepare the result, and activation
applies it to a system or home environment.

Start with the [architecture](docs/architecture.md) for ownership and composition,
then the [technical contracts](docs/contracts.md) for exported interfaces and
preference examples. Keep credentials outside plaintext Git and ordinary Nix
values: private repositories and Nix store paths are not secret vaults.

## Further reading

- [Experimental user environment: standalone Home Manager and a development VM](examples/portability/README.md)
- [Selecting, disabling and validating LazyVim](docs/applications/lazyvim.md)
- [Roadmap and v0.1 validation status](docs/roadmap.md)
- [Architecture and longer-term direction](docs/architecture.md)
- [Configuration contracts](docs/contracts.md)
- [Glossary](docs/glossary.md)
- [Contributing](CONTRIBUTING.md)
- [Contributor and coding-agent rules](AGENTS.md)
