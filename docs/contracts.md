# ijs — Technical contracts

## Purpose and status

This document describes the technical interfaces between reusable ijs infrastructure and the configurations that consume it.

Interfaces are labeled as **implemented** or **proposed** to avoid confusing working functionality with future design plans.

The preferred implementation strategy is to use standard NixOS, Home Manager, flake-parts and Nix module mechanisms wherever possible.

## 1. Flake dependency contract

**Status: Implemented and build-tested**

An installation-specific flake declares ijs as an input.

A published installation may use a dependency such as:

```nix
inputs.ijs.url = "github:OWNER/ijs";
```

`OWNER` is a placeholder. The consuming flake's lock file pins the resolved revision.

During development, the dependency can be overridden with another local flake source.

The public infrastructure must not require a fixed installation path or know where a consumer's private files are stored.

A flake dependency is not a mechanism for storing or protecting secrets.

## 2. Module registration contract

**Status: Implemented and build-tested**

ijs uses flake-parts and its module registry:

```nix
inputs.flake-parts.flakeModules.modules
```

The public registry exports reusable modules under:

```nix
flake.modules.nixos.<name>
flake.modules.homeManager.<name>
```

Consumers access them through the ijs flake input.

For example:

```nix
inputs.ijs.modules.nixos.workstation
inputs.ijs.modules.homeManager.hyprland
```

Registering a module does not activate it.

An actual configuration must explicitly select the module in its NixOS or Home Manager `imports`.

NixOS modules, Home Manager modules and flake-parts modules have different evaluation contexts. They must not be treated as interchangeable.

## 3. Preference loading contract

**Status: Implemented and build-tested**

The public helper is exported as:

```nix
inputs.ijs.ijs.loadPreferences
```

It accepts an attribute set containing:

```nix
{
  pkgs = ...;
  directory = ...;
}
```

The directory contains these preference declarations:

```text
preferences/
├── applications.nix
├── appearance.nix
├── bindings.nix
└── input.nix
```

The helper returns the resolved preference attribute set.

An example of the current usage pattern is:

```nix
preferences = inputs.ijs.ijs.loadPreferences {
  inherit pkgs;
  directory = ./preferences;
};
```

The loader must not assume a particular username, hostname or private source path.

The caller chooses the preference directory.

## 4. Theme resolution contract

**Status: Implemented and build-tested**

Theme resolution uses:

```nix
inputs.ijs.ijs.resolveTheme
```

The current helper is called with the Nix library and then the selected theme name.

```nix
theme = (inputs.ijs.ijs.resolveTheme {
  inherit lib;
}) preferences.appearance.theme;
```

The resulting theme is supplied to the Home Manager configuration.

The public starter currently selects `mocha-purple`.

The intended design is for themes to remain independent of user identity and desktop implementation.

## 5. Home Manager composition contract

**Status: Implemented and build-tested**

The user composition loads preferences and resolves the theme before importing the selected Home Manager modules.

The current mechanism injects:

```nix
_module.args = {
  inherit preferences theme;
};
```

Desktop modules receive those arguments and use shared translators to generate native configuration.

This avoids importing a particular user's preference directory inside reusable desktop modules.

A typed Home Manager option may replace the current argument-based interface in a future version.

The public starter uses Hyprland and Waybar, while the private composition can independently select its own modules.

## 6. Desktop translation contract

**Status: Implemented for supported actions**

Shared preferences define semantic actions such as:

```nix
applications.terminal = "SUPER+T";
windows.close = "SUPER+Q";
```

Desktop adapters map these semantic actions to supported native operations.

Hyprland uses its Lua configuration interface. Niri uses KDL configuration.

Application choices are resolved separately from their keyboard shortcuts.

Adapters are responsible for implementing supported actions and should not silently ignore mandatory requirements.

The current translation system should not be interpreted as a complete universal desktop API.

## 7. Host authority and capability activation

**Status: Static Nix module composition implemented; advanced negotiation proposed**

The host is responsible for:

- Hardware and storage configuration
- Account creation
- Administrative permissions
- Privileged system services
- Firewall and network policy
- Authorization for VM management

A portable Home Manager configuration can request applications and user-level functionality, but it does not automatically gain privileges.

Module registration and feature availability are distinct from feature activation.

The future capability-negotiation system must respect both enforceable host restrictions and mandatory user requirements.

## 8. Compatibility and policy results

**Status: Proposed**

A future pure validator may return structured compatibility results.

Illustrative format:

```nix
{
  compatible = false;

  reasons = [
    {
      code = "software.nonfree-host";
      message = "The host does not satisfy the user's software policy.";
    }
  ];
}
```

This is a proposed data contract, not a finished policy engine.

Mandatory requirements must be treated as constraints rather than ordinary preferences.

Nix's `lib.mkDefault` and `lib.mkForce` are module merge mechanisms, not substitutes for security enforcement.

The system should reject incompatible mandatory requirements with clear explanations instead of silently weakening them.

## 9. Package selection contract

**Status: Static package lists implemented; dynamic selection proposed**

Nix derivations define packages and their dependencies.

Home Manager imports determine which user applications become part of the built environment.

The current public starter uses `desktop-basics.nix`. Additional applications remain available through other module selections.

User preferences identify application choices, but the current implementation does not provide general automatic package negotiation or download-on-first-launch behavior.

Any future provisioning mechanism must respect user consent and host software policies.

## 10. VM and session contracts

**Status: Experimental design**

A future VM example should combine a generic NixOS host definition with a selectable user configuration.

VM resources such as memory, CPU allocation and storage must be configured independently from personal application preferences.

The public example must not reuse actual host disk identifiers, credentials or network identity.

The longer-term session model may distinguish:

- Native sessions on trusted hosts
- Isolated guest sessions
- Lightweight terminal-based sessions

Such environments provide different isolation guarantees.

The current repository does not implement automatic VM allocation, remote authentication, live migration or runtime session negotiation.

## 11. Security and publication contract

**Status: Mandatory project rule**

Reusable implementation belongs in public ijs.

Installation-specific host settings and personal selections may be maintained in separate private repositories.

Neither public nor private Git repositories should contain plaintext passwords, private keys, recovery keys or API tokens.

Private repositories are not secret vaults.

Secret values must not be embedded in ordinary Nix configuration expressions where they could enter Nix store paths or generated files.

Before publishing changes:

1. Review staged files and repository history.
2. Scan for credentials and sensitive identifiers.
3. Evaluate and build affected configurations.
4. Document significant interfaces or security changes.
5. Avoid claiming runtime validation when only builds have been tested.

## 12. Compatibility and future development

New reusable features should be contributed through public modules and documented interfaces.

Private configurations should select or parameterize capabilities rather than copying public implementation code.

Breaking public API changes should be intentional, documented and tested against the standard example and representative consuming configurations.

The current `inputs.ijs.ijs.*` helper namespace is functional but may be simplified in a future version. Such a change should be treated as an API migration, not a cosmetic edit.

The goal is to let contributors improve ijs collectively while preserving portable configurations across different hosts, users and deployment types.
