# Session provisioning contract (v1 design)

A user may request a native desktop session, a VM with specific resources (for
example 16 GiB RAM), or a minimal terminal/controller session. The host
advertises **declared** supported modes and available resources. Both sides
express non-negotiable restrictions. A pre-provisioning match must return
structured, human-readable reasons on rejection. The user may later be offered
alternatives, but no mandatory security requirement is relaxed automatically.

The pure prototype at `lib/negotiation/default.nix` checks session-mode overlap,
minimum available memory, and one software-freedom condition. It is a **design
probe only** and does not allocate a VM, authenticate users, measure free RAM
at runtime, lazily install applications, or prove remote host integrity.

Security/permission constraints remain host-enforced at runtime; community
provisioning will require authenticated identities, resource reservations,
attestation strategy, isolated sessions, and teardown verification.

## Resource request (illustrative)

```nix
{ allowedModes = [ "vm" "terminal" ]; minMemoryMiB = 16384; }
```

The host must not start a less-isolated mode just because it has insufficient
RAM; it must reject or offer an explicitly consented compatible alternative.
