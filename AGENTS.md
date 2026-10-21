# Contributor / coding-agent contract

This project is intended to teach and demonstrate reproducible, security-first infrastructure.

1. **Explain purpose before mechanism.** Every Nix module begins with comments: purpose, layer/class, why enabled, dependencies, customization path and security effects. Group packages by function and comment unfamiliar items.
2. **Don't infer user intent from folder existence.** Registering an inactive feature must not install packages, open firewall ports, or grant privileges.
3. **Never hardcode a personal identity in reusable implementation.** Preferences come from chosen user configuration and are passed into adapters.
4. **Host owns privilege and network policy.** Don't add users to `wheel`, `libvirtd`, `kvm`, open ports, or weaken restrictions through a user preference.
5. **Do not silently weaken requirements.** Mandatory software-freedom, isolation and encryption constraints must reject incompatible configurations with a human-readable reason.
6. **Do not guess at unknown flake-parts APIs.** Check the docs and distinguish flake-level modules from NixOS/Home Manager modules.
7. **Preserve proven behavior.** Keep the Hyprland Lua v0.56 API, KDL templates, shared action script, Waybar controls and working shortcuts unless a tested replacement is required.
8. **Avoid piecemeal structural migrations.** Plan and review the full migration map, then implement in one branch/snapshot; build before activating.
9. **Never include private credentials, user files, VM disks or machine-specific unpublished metadata in commits.** Review staged contents and run secret checks.
10. **Be truthful about test coverage.** No claim of successful `nix flake check` or secure sandboxing without running the relevant test.
11. **Write short, understandable Nix.** Prefer module contracts and typed options to custom resolution engines; keep example data separate from activated configuration.
12. **Make every security exception explicit.** State the threat/trust assumption, authorizing operator, affected resource, and future review condition.

## Mandatory source documentation

Every added or modified source file must start with a valid comment header
explaining purpose, role/consumer, customization and relevant security concerns.
Explain non-obvious design choices near their implementation. Do not add
comments to strict JSON files or lockfiles; document those nearby instead.
Prefer preserving working behavior over gratuitous refactors. If a module
clearly violates a host/user/feature ownership boundary, propose the smallest
justified move; obtain approval for changes affecting functionality, activation,
security, package sets or major folder conventions. Record unresolved architectural
decisions in GitHub issues or documented design proposals before implementing
significant changes.

## Public and personal configuration

The public ijs repository owns reusable functionality, interfaces,
documentation and example configurations.

Real machine definitions and personal preferences belong in separate
configuration repositories. Neither public nor private repositories
may contain plaintext credentials or cryptographic private keys.

Public modules must not depend on a particular username, hostname,
home directory or local repository path.

Prefer small, reviewable changes on dedicated Git branches.
Test reusable changes against public examples, not only against
one developer's private installation.
