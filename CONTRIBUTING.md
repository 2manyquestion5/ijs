# Contributing to ijs

Small fixes, clearer documentation and reproducible bug reports are welcome.
ijs is a practical computing environment and a learning project: help make it
understandable as well as reliable.

## Before adding code

Look for an existing NixOS option, Home Manager module or application feature
that meets the requirement. Maintained native functionality is usually easier
to carry between systems than a custom script or background service.

Keep changes focused on one problem. Preserve working behavior, explain unusual
choices near the code, and add dependencies or abstractions only when their
benefit is clear. Keep experiments separate from stable defaults; distinguish
an actual defect from a design preference or an unfinished capability.

Public ijs owns reusable modules, interfaces and examples. Consuming
configurations own actual hosts, accounts and personal selections. See
[architecture](docs/architecture.md) for ownership and composition and
[technical contracts](docs/contracts.md) for the current interfaces. A workspace
name or configuration default does not itself enforce isolation.

Read [AGENTS.md](AGENTS.md) for repository rules and the
[commenting standard](docs/commenting-standard.md) when changing source files.

## A small-change workflow

Start with a clean checkout. If you have local changes, preserve them before
switching branches; do not discard them to follow these instructions.

```bash
git status --short --branch
git fetch origin
git switch main
git merge --ff-only origin/main
git switch -c change/short-description
```

Use a descriptive branch name in place of `change/short-description`. Work on
one concern and review the diff as you go. A cloud workspace, your local
checkout and GitHub are separate copies; changes move between them through
explicit commits, pushes and fetches.

## Validate what changed

For configuration changes, start with evaluation of the public example, from
the repository root:

```bash
nix --extra-experimental-features 'nix-command flakes' eval \
  --raw --no-write-lock-file \
  .#homeConfigurations.example.activationPackage.drvPath
```

This resolves the build derivation; it does not build the complete output. Use
[the README's build command](README.md#build-the-public-example) for that step.
Test a consuming configuration too when a change affects host integration.
Use focused parser checks, isolated application tests or VM tests where they
answer a real question. Documentation changes need link and command checks;
they do not automatically require a full system build.

Report the revision, commands, results and limitations. Keep evaluation,
successful builds and runtime tests distinct. A build does not establish that
locking, suspend, networking or hardware behavior works. Current release
coverage and pending runtime tests belong in the [roadmap](docs/roadmap.md).

Building prepares artifacts in the Nix store. **Activation applies a built
configuration to a system or home environment.** Do not activate a contributor's
change on someone else's machine as part of routine validation. Deployment is a
separate decision with a recovery plan.

## Review and publish

Stage only intended files, then inspect the staged diff and whitespace checks:

```bash
git diff --check
git diff --cached --check
git diff --cached
```

Before committing, check the effective Git identities with
`git var GIT_AUTHOR_IDENT` and `git var GIT_COMMITTER_IDENT`. Choose the public
name and email you intend to disclose; set repository-local Git configuration
if needed. After committing, inspect **both** metadata fields on every new
commit before pushing:

```bash
git log origin/main..HEAD --format='%h %s%nAuthor: %an <%ae>%nCommitter: %cn <%ce>'
```

Check new files, the PR description and any history being published for
credentials and private information. See the
[security and publication guide](docs/security-and-publication.md) for what to
look for. GitHub-created squash commits use GitHub account identity settings;
local Git configuration alone does not control that metadata.

Push the focused branch and open a PR against `main`; use a draft when feedback
or validation is still pending. Explain the problem, the change, how it was
tested and what remains untested. Include short review or verification steps
when useful. Merge after review; handle consumer input updates and activation
separately rather than folding deployment into a public-module PR.
