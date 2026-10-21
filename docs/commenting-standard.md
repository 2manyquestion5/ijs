# Repository documentation and commenting standard

**Purpose:** Make every component understandable without requiring access to its original author.
**Status:** Adopted for this documentation pass; runtime semantics were intentionally preserved.

## Every source file

A readable source file should identify **what it does**, **why it exists**, **who imports or uses it**, and **where to customize it**.
For modules touching boot, networking, privilege or persistence, also explain the security or recovery implications.
Prefer comments near non-obvious code: they should document *reasoning*, not repeat what Nix, Lua, KDL or shell syntax already says.

Do not add comments that break syntax: keep shell shebangs first; use `//` for KDL/JSONC, `--` for Lua, `/* ... */` for CSS and `#` for Nix and native config formats. Pure data files, including `flake.lock`, cannot carry comments; explain them in a nearby Markdown document.

## Changes and ownership

- Preserve verified application behavior and existing working API contracts.
- Separate host authorization from user preferences.
- Organize selected programs by use, but don't silently change which packages are installed.
- Split files only when the ownership boundary is unambiguous.
- Record decisions involving behavior, privileges, dependencies or deployment as review items first.
- For another machine, create a fresh host directory and generate its own disk identifiers and filesystem mappings.
- A header saying PRIVATE is not access control; inspect all contents before any Git commit.

## Checks needed

Run syntax and Nix evaluation, then builds, VM tests and eventually controlled physical activation. No successful runtime/build test is claimed by this documentation-only pass.
