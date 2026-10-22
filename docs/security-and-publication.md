# Security and publication

This is reusable review guidance, not a security audit of the current system.
See [the roadmap](roadmap.md) for recorded validation evidence and
[CONTRIBUTING.md](../CONTRIBUTING.md) for the development workflow.

## Public configuration and sensitive information

Public ijs contains reusable modules, sanitized examples, interfaces and
technical documentation. Actual host definitions, storage identifiers, account
choices and confidential network details belong in the consuming configuration,
unless deliberately reviewed for publication.

Neither public nor private Git repositories are secret vaults. Keep passwords,
API tokens, private keys, recovery material and Wi-Fi secrets out of plaintext
Git and ordinary Nix values. Nix source, store paths and generated artifacts
must not be assumed confidential. Secret-management tools need explicit choices
about encryption, recipients and where decrypted values are made available.

Handle sensitive source material with appropriately restricted file permissions
and secure backups. Protect backup copies with access controls and encryption
appropriate to their contents; keep secrets and backup copies out of Git.

User files, browser profiles, SSH agent data, service state and VM disks are
not reusable source configuration. Review example data and screenshots too.
Choose a public Git identity deliberately: author and committer fields are
published along with commit messages, PR text and comments.

## Before publishing a change

- Inspect tracked, untracked and ignored files, the staged paths and diff, and
  every commit being pushed. When publishing existing history, review it too.
- Check for credentials, private identities, local paths, hardware identifiers
  and confidential host or network information. A secret scanner such as
  `gitleaks` can help; inspect its findings and state what was actually scanned.
- Check both author and committer metadata and the PR text. Repository-local
  identity settings do not change existing commits or GitHub-created commits.
- Check generated files and build outputs before sharing them. Sanitizing the
  source does not prove that a log or artifact contains no sensitive data.

From the repository root, list tracked files and inspect working-tree status,
including untracked and ignored files:

```bash
git ls-files
git status --short --ignored --untracked-files=all
```

Review this output locally; do not publish sensitive filenames or contents.

`.gitignore` helps prevent accidental additions, but does not encrypt files,
remove tracked files or clean Git history. A header saying PRIVATE is not access
control. Removing a file from the latest commit does not remove earlier copies.
If a credential was exposed, revoke or rotate it first; coordinate any history
cleanup separately. Avoid quoting the exposed value in reports or PRs.

## Runtime boundaries and deployment

Hosts authorize accounts, privileged groups, services and network access. User
preferences and Home Manager selections do not grant those permissions. An
imported NixOS module can enable privileged services in the generated system;
review its declarations before building and activating it.

Explicitly enable host firewall protection and minimize unnecessary exposed
services. Verify effective firewall and service behavior on the deployed host;
do not infer that a port is closed, a route is restricted or a VM is isolated
just because a configuration option exists. Use tests appropriate to the claimed
boundary. Preserve independent recovery access, such as a local console, before
potentially disruptive networking or filtering changes.
Hyprland workspaces organize windows; they do not isolate processes, storage,
credentials or networks.

VMs and containers provide different boundaries. Untrusted VM workloads should
have restricted networking and no unnecessary clipboard, folder, device or
credential sharing by default. Review and justify any exceptions; neither a VM
label nor a workspace label establishes a security guarantee. The current
negotiation prototype checks declared inputs, not remote host integrity.

Build before activation. Keep the working boot and storage configuration intact
while preparing a candidate, and document recovery and rollback in the consuming
repository. Do not change disk identifiers or state-version settings merely to
make an example look generic. Use placeholders in public examples instead.

## Historical migration context

Earlier versions of this document mixed publication guidance with observations
from an initial source archive and migration review. Those observations were
specific to that snapshot, not evidence about the current checkout or any
running machine. They are not carried forward as current security findings.

Host-specific follow-up and deployment decisions belong in the consuming
repository. New verification results should record their revision, method and
limits; update the public roadmap only with evidence suitable for publication.
