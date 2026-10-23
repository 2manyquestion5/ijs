# LazyVim integration

The exported `ijs.modules.homeManager.lazyvim` module includes its upstream
Home Manager dependency, editor defaults and compatibility repairs. Consumers
select one module; they do not need a separate upstream import.

## Select, customize or replace

In a consuming Home Manager module with the public input named `ijs`:

```nix
{ inputs, lib, ... }:
{
  imports = [ inputs.ijs.modules.homeManager.lazyvim ];
  _module.args.theme =
    (inputs.ijs.ijs.resolveTheme { inherit lib; }) "mocha-purple";
}
```

The public starter already supplies the theme argument. Native
`programs.lazyvim` options remain available. Nix/Python extras and Catppuccin's
flavour are defaults that users can override; the module does not select an
active colorscheme. LazyVim's pinned default remains TokyoNight.

Disable the integration with an ordinary assignment:

```nix
programs.lazyvim.enable = false;
```

Its managed files, editor enablement and dependency declarations then disappear
unless another module configures them independently. No theme argument or
compatibility patch evaluation is required when disabled. Configuration changes
take effect only after the consuming environment is deliberately activated.

To replace it while retaining the import:

```nix
programs.lazyvim.enable = false;
programs.neovim.enable = true;
```

Alternatively, remove the LazyVim import and select ordinary Neovim directly.
Do not compose competing owners for the same `nvim` configuration. Previously
importing the identical upstream module path separately is harmless because
Nix deduplicates it, but that extra import is no longer necessary.

## Supported scope and retained data

This integration supports `programs.lazyvim.appName = "nvim"`, the default
Neovim configuration namespace. Other app names fail explicitly while LazyVim
is enabled; they are not supported by this compatibility repair. Launching with
a different `NVIM_APPNAME` is also outside this supported namespace.

It uses Home Manager's XDG configuration/data paths and Nix-managed plugin
sources. Extend it with explicit packaged dependencies; arbitrary Lua plugin
specifications do not automatically acquire a complete Nix dependency closure.
The pinned upstream module also scans an existing plugin directory when it is
visible to the evaluator. Do not rely on local-home discovery for reproducible
configuration: keep required plugin declarations in source.

Normal Home Manager activation removes obsolete links it owns. It does not
delete user-created configuration, caches, plugin checkouts, databases or other
data. Such files may still affect a replacement editor. An unmanaged conflicting
file should be reviewed rather than overwritten or deleted automatically.
This module introduces no cleanup command and no system-wide network restriction.

## Compatibility repairs

These apply to `pfassina/lazyvim-nix` revision `2189337` and LazyVim v16.0.1.
The implementation is local to
[lazyvim.nix](../../modules/home/programs/lazyvim.nix) and
[lazyvim-init.nix](../../modules/home/programs/lazyvim-init.nix).

| Problem | Repair | Removal condition |
|---|---|---|
| The generated starter clones Lazy.nvim despite packaging it. A bootstrap symlink under Lazy's install directory can still be classified incorrectly. | Load the manager directly from its real Nix store path. | Upstream loads the packaged manager without a bootstrap or install-root alias. |
| LazyVim defaults to Blink on clean homes, but upstream only packages explicitly selected extras. | Select the supported Blink extra and supply Nixpkgs' packaged native backend. Disable Blink's separate binary downloader. | Upstream packages the default completion dependency, including its native backend, without runtime downloads. |
| The upstream manifest omits friendly-snippets. | Supply its Nix-managed plugin path explicitly. | Upstream includes this dependency with the correct identity. |
| Upstream generates `nvim` as the identity of `catppuccin/nvim`. | Use `catppuccin`, retaining the exact resolved upstream theme source. | Upstream honors the plugin's explicit identity. |
| Missing-plugin installation and Lua-rock provisioning remain enabled. | Disable both, retain the disabled update checker, and report incomplete packaged plugin sets. | Upstream supports equivalent declarative installer controls; ijs retains its no-startup-installation choice. |

The helper checks known template sections and the starter revision before
replacement. A changed template requires review, not an unchecked patch.
Compatibility fixes cannot be independently disabled while claiming this
integration is supported. Native overrides remain available to consumers who
intentionally supply their own complete implementation. No dependency pins are
updated by this repair. Packaging fixes are candidates for upstream contribution.

## Validate without activation

From the public checkout on `x86_64-linux`:

```sh
nix build -L --no-write-lock-file --no-link .#checks.x86_64-linux.lazyvim-offline
nix build -L --no-write-lock-file --no-link .#checks.x86_64-linux.lazyvim-lifecycle
nix build --no-write-lock-file --no-link .#homeConfigurations.example.activationPackage
```

The offline check runs the actual wrapped editor in fresh homes and with
existing user files and a legacy bootstrap link. It checks packaged plugins,
Blink's native backend, snippets and the theme. Negative cases test the
missing/misnamed-plugin assertions and Git installer guard; those mutations
happen after initialization. This is focused packaging coverage, not a general
audit of arbitrary plugins or language-server behavior.

The lifecycle check evaluates disabled/plain compositions without a theme,
rejects unsupported app names, and uses Home Manager's own collision/link
phases in a disposable home. It transitions through enabled, disabled and
plain Neovim configurations, runs the replacement editor and verifies that
unmanaged files remain. A conflicting user `init.lua` must block file linking.
It does not install profiles, run a full Home Manager
activation or test a physical workstation. A failed or unavailable build is not
a passed runtime test.

See [architecture](../architecture.md) for ownership and
[the roadmap](../roadmap.md) for broader validation boundaries.
