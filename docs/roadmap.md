# ijs — Roadmap and validation status

**v0.1 is in preparation, not released.** The immediate goal is a reliable
first-deployment candidate, not a redesign or a completed distributed platform.
The [README](../README.md) explains how to build the public starter;
[architecture](architecture.md) describes current boundaries and longer-term
direction.

## Reading the evidence

- **Merged:** code is on public `main`; this alone says nothing about runtime.
- **Evaluated:** Nix resolved the selected declarations or build derivation.
- **Built:** the complete selected output was produced successfully.
- **Runtime-tested:** the named behavior was exercised in a live session.

Evidence applies to the revision and configuration tested. A Home Manager build
does not validate a NixOS host, hardware behavior or a graphical session. Local
results below are maintainer-reported; cloud checks are not a replacement for
local runtime testing.

## Current v0.1 preparation

Implementation baseline: `56567cd` (merged battery cleanup, PR #6). This is an
evidence snapshot, not a release tag. The documentation changes do not change
the Nix configuration.

| Area | Merged change and evidence | Remaining validation |
|---|---|---|
| Waybar network traffic | [PR #1](https://github.com/2manyquestion5/ijs/pull/1) uses the native module; local starter build passed. | Live rates, interface selection and disconnected display. |
| Locking and idle handling | [PR #2](https://github.com/2manyquestion5/ijs/pull/2) adds NixOS Hyprlock/PAM integration alongside the existing Hypridle integration; local starter and consuming NixOS builds passed with the public override. | Lock/unlock, idle startup and suspend/resume in the intended UWSM session. |
| tmux clipboard | [PR #3](https://github.com/2manyquestion5/ijs/pull/3) repairs the bindings with packaged `wl-copy` paths; isolated tmux checks and local Wayland clipboard testing passed. | Recheck within the first deployed environment. |
| Additional applications | [PR #4](https://github.com/2manyquestion5/ijs/pull/4) adds native Home Manager GitHub CLI and Yazi support, plus archive tools, to the optional `packages` collection. Evaluation and package availability checks passed. | Build and exercise a consumer selecting this collection; the minimal starter does not import it. |
| Clipboard history | [PR #5](https://github.com/2manyquestion5/ijs/pull/5) removes the public default history shortcut and unused starter package; generated bindings were checked and the local starter build passed. | Confirm ordinary clipboard behavior during deployment; consumers must review their own shortcuts. Existing history data is not deleted. |
| Waybar aggregate battery | [PR #6](https://github.com/2manyquestion5/ijs/pull/6) replaces custom sampling with native weighted aggregation; evaluation and source/generated JSONC checks passed. Individual indicators are unchanged. | A complete local build of this baseline, live readings, charging behavior and presentation on the deployment hardware. |

Earlier local builds are evidence for those revisions, not a successful build of
every later `main`. The latest baseline still needs a complete local starter
build. During this documentation pass, a fresh public clone at the baseline
successfully evaluated the starter's build derivation. The full build was
attempted but blocked by the relocated cloud Nix environment: builders expect
executable paths under `/nix/store` that are unavailable there. This is a build
limitation, not a successful build or a fully verified clone-to-build run.

## Remaining release gates

1. **Finish documentation in focused passes.** Establish newcomer guidance,
   reconcile public terminology and contribution instructions, then prepare
   private operational documentation separately. Do not publish actual host
   details in the public guide.
2. **Add essential repeatable checks.** Keep a fresh-checkout starter build and
   generated-configuration checks reproducible. Automated CI coverage is not yet
   established; select a small useful set before treating it as a release gate.
3. **Prepare the consuming configuration.** Explicitly select the intended
   graphical session, update its public input after review, and reconcile
   consumer-specific shortcuts and application selections. Build both the
   Home Manager and NixOS outputs at the exact candidate revision.
4. **Prepare deployment and rollback.** Record the known working configuration,
   candidate revision, activation steps, recovery access and rollback procedure
   in the consuming repository. A successful build is required before an
   explicitly approved deployment.
5. **Run a controlled first deployment.** Test locking and idle handling first,
   then suspend/resume, clipboard, Waybar network and battery displays, launchers
   and essential development tools. Record actual results and remaining gaps;
   do not mark runtime behavior as tested in advance.
6. **Review the release candidate.** Reconcile evidence, known limitations and
   documentation before deciding whether v0.1 is ready to tag. No release or
   activation follows automatically from a merged PR.

## Experimental and later work

These directions do not block the initial Hyprland deployment:

- Niri is experimental; Noctalia integration is planned. Neither is an accepted
  replacement for the initial starter yet.
- A small reproducible VM example could demonstrate reuse of selected user
  tools with different host permissions. Existing virtualization support is
  not a finished guest lifecycle manager; the lab-server role is a placeholder.
- Selective sharing of configuration, credentials and data, and explicit
  workspace/network boundaries need concrete examples and enforcement tests.
- Session negotiation is a design prototype. Cross-host authentication,
  provisioning and orchestration remain research directions.

Prefer application and Home Manager features over custom services where they
meet the need. Extend the architecture through small working examples, rather
than adding abstractions in anticipation of future requirements.
