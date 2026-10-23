# One user environment, two Home Manager modes

This experimental example selects the same [user environment](home.nix) through
standalone Home Manager and through Home Manager's standard NixOS integration.
It reuses ijs's LazyVim and tmux modules and adds Git, ripgrep and fd. These five
commands are available in the user's terminal: `git`, `nvim`, `tmux`, `rg`, `fd`.
LazyVim also brings editor dependencies; those are not all terminal packages.

Both examples use the generic account name `example`. They contain no personal
identity, Git author settings, credentials or workstation hardware configuration.
The existing desktop starter is unchanged. Actual installations do not select
this example automatically.
This is a composition experiment, not an installer or a complete workstation.

## Build without activation

Run from the public ijs checkout on `x86_64-linux` with Nix flakes enabled:

```bash
nix build --no-write-lock-file --out-link result-portability-home \
  .#homeConfigurations.portability.activationPackage
nix build --no-write-lock-file --out-link result-portability-integrated-home \
  .#nixosConfigurations.development-vm.config.home-manager.users.example.home.activationPackage
nix build --no-write-lock-file --out-link result-portability-vm \
  .#nixosConfigurations.development-vm.config.system.build.vm
```

Building creates store outputs and result links; it does not activate the example
in your home or on your host. **Do not run either example's `activate` script on
your own account, or deploy this VM configuration to physical hardware.**
The standalone output builds a hypothetical `/home/example`; it does not create
that operating-system account.

## Launch the VM

QEMU runs as your ordinary user, without libvirt or host service changes. KVM
access is recommended on a compatible Linux host. Keep guest disk state outside
the checkout:

```bash
vm_output=$(realpath result-portability-vm)
vm_state=$(mktemp -d -t ijs-portability.XXXXXX)
printf 'Guest disk directory: %s\n' "$vm_state"
(cd "$vm_state" && "$vm_output/bin/run-ijs-development-vm")
```

The terminal console logs in automatically as `example`, without administrative
groups or a configured login password. This is an explicit convenience for a
trusted local VM console, not a production account policy. Do not expose its
console to untrusted users. SSH is disabled, networking is restricted with no
forwarded ports, and host folders and the host store are not mounted into the
guest. A guest-specific Nix store image is prepared at launch; it can take time
and substantial disk space. The guest root disk persists in `vm_state`.
The store image stays read-only, with a guest-local writable overlay so Nix and
Home Manager can initialize. That overlay uses the default tmpfs and is discarded
on reboot; persistent in-guest package builds are outside this example's scope.

Inside the VM, try:

```bash
git --version
rg --version
fd --version
tmux
```

In tmux, the prefix is **Ctrl-Space**. Press the prefix then `[` for vi copy
mode; start a selection with Space, move with vi keys and copy with `y` or Enter.
Paste with the prefix then `]`. Copies stay in tmux's buffer; this example does
not connect to the host clipboard. Run `nvim` to inspect the shared editor.

To request guest shutdown, open QEMU's monitor with **Ctrl-a, c** and enter
`system_powerdown`. **Ctrl-a, x** exits QEMU immediately if needed. Keep the
printed `vm_state` path if you want to reuse the guest disk in a later launch;
launching from a new directory creates a fresh guest.

## Run the focused checks

```bash
nix build --no-write-lock-file --no-link .#checks.x86_64-linux.tmux-clipboard
nix build --no-write-lock-file --no-link .#checks.x86_64-linux.lazyvim-offline
nix build --no-write-lock-file --no-link .#checks.x86_64-linux.lazyvim-lifecycle
nix build --no-write-lock-file --no-link .#checks.x86_64-linux.portability-vm
```

The tmux check loads both generated configurations on isolated servers. It
checks the preserved Wayland commands without invoking `wl-copy`, and exercises
`y` and Enter against tmux's buffer in terminal mode. The VM check boots a guest,
checks integrated Home Manager activation and runs the shared LazyVim regression
assertions against the VM user's actual wrapped editor. A test-only Git guard
reports attempted plugin installation; the guest's restricted networking remains
unchanged. These focused checks do not audit every possible application network
operation. The editor's separate checks cover clean/existing homes and managed
file transitions without activating the host.
A successful evaluation or build alone does not demonstrate that the VM booted.

Earlier local runs confirmed VM boot, Home Manager activation and CLI version
checks after correcting the read-only guest store, but editor startup failed.
The application repair merged in PR #10 subsequently passed maintainer-reported
local editor runtime/lifecycle checks and the public Home Manager starter build.
This example now selects that repaired public module. A complete successful VM
test of this integration is still pending; cloud builds remain limited by the
relocated store and KVM is unavailable there. Evaluation is not a completed build
or VM run. The editor test has a timeout, and service status/journals are printed
if Home Manager activation fails.

## How composition works

[The output wiring](../../modules/flake/portability.nix) passes one list of user
modules to both `homeManagerConfiguration.modules` and
`home-manager.sharedModules`. Both receive `ijs` through Home Manager's standard
extra arguments. The standalone wrapper supplies the account name and home;
the integrated version gets them from the [NixOS guest account](vm.nix).
The integrated example uses the host package set and NixOS user-package support.
Both select the same tools and generate the same editor and tmux configuration;
their activation scripts and support packages can differ between deployment modes.
The shared module imports `ijs.modules.homeManager.lazyvim`, which owns its
upstream import, dependencies and compatibility handling. The example contains
no bootstrap symlink workaround. See the [application documentation](../../docs/applications/lazyvim.md)
for selection, overrides and limitations.

The shared module selects a theme and disables the new
`ijs.tmux.waylandClipboard.enable` option for these terminal examples. Its
default remains `true` elsewhere, preserving existing Wayland behavior.

More users or hosts can import the same module and supply their own selections.
There is no profile engine, account synchronization, secret distribution,
remote deployment, graphical preview or fleet orchestration here. No claim of
complete VM isolation or production readiness follows from this example.

See [architecture](../../docs/architecture.md) for ownership boundaries and the
[public README](../../README.md) for the unchanged desktop Home Manager starter.
