# Session negotiation — experimental design

This is a design probe, not the v0.1 release contract. The
[technical contracts](contracts.md) distinguish implemented interfaces from
proposals; [the roadmap](roadmap.md) records release scope.

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

Security and permissions need host-enforced runtime mechanisms. A future remote
provisioning design would need to address authentication, resource reservation,
trust assumptions, isolation and teardown; no particular attestation system or
orchestration architecture has been selected.

## Run the prototype

From the repository root, with Nix installed:

```bash
nix --extra-experimental-features 'nix-command flakes' eval --impure --json \
  --expr 'import ./examples/negotiation.nix'
```

`--impure` allows this standalone expression to read the local checkout and
resolve its flake through `builtins.getFlake`; the example uses that flake's
pinned nixpkgs input. It does not activate a configuration or provision a session.
Evaluate source you trust: this flag relaxes pure evaluation restrictions.

The example requests more memory than its declared host provides, so it returns:

```json
{"compatible":false,"reasons":["insufficient-memory"],"selectedMode":null}
```

These reason strings are the prototype's current output, not the proposed
structured reason objects described in the technical contracts.

## Resource request (illustrative)

```nix
{ allowedModes = [ "vm" "terminal" ]; minMemoryMiB = 16384; }
```

The host must not start a less-isolated mode just because it has insufficient
RAM; it must reject or offer an explicitly consented compatible alternative.
