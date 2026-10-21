# Security and publication checklist

**Do not upload the supplied source snapshot unchanged.** Hardware, storage and LUKS UUIDs can identify the machine; `extraHosts` contains private lab network names and addresses. No obvious passwords/private keys were found in the archive scan, but that is not proof of safety. The archive is a snapshot and may be stale.

## Runtime baseline

- Keep NixOS firewall explicitly enabled. Existing `nft` evidence showed filtering working, with libvirt's dedicated bridge rules. Check effective *runtime* behavior again after the migration.
- Restore reverse-path filtering only with a local recovery route; assess VM network effects. No current VPN use has been reported.
- Disable unnecessary incoming SSH, Avahi/mDNS, printing and Bluetooth when a selected role does not need them. GNOME currently requests Avahi; document any `mkForce false` override rather than burying it.
- Declare privileged membership (`wheel`, `libvirtd`, `kvm`) **only** via host authorization. KVM access and virtualization management can be security sensitive; do not grant them to visiting users by profile.
- Use restricted default networking for untrusted VM workloads; no clipboard, device passthrough, shared folders, or host credentials unless justified. VM isolation reduces risk but is not a malware-proof guarantee.
- Do not edit the active LUKS mapping, hardware UUIDs, `system.stateVersion` (`26.05`) or `home.stateVersion` (`26.05`) for cosmetic portability. Abstract machine-specific identifiers into a private machine overlay/example instead; preserve actual bootable config locally.
- A group access policy needs actual auth implementation before dynamic login is exposed. Never allow arbitrary user configs to change host NixOS modules.

## Public repository data policy

**Allowed after review:** reusable Nix modules, examples, source templates, documented policy, pure functions, pinned flake lock, sanitized host example.

**Private by default:** private keys, SSH agent data, tokens, API credentials, passwords, Wi-Fi secrets, user files, browser profiles, service state, VM disks, confidential network topology, device identifiers the operator wants private.

Proposed ignore additions (`.gitignore` alone is insufficient):

```gitignore
# Nix outputs and caches
/result
/result-*
.direnv/
.venv/
# Editor artifacts
*.swp
*.swo
*~
*.save
*.bak
# Environment and credentials
.env
.env.*
*.key
*.pem
*.age
*.p12
*.pfx
/secrets/
/credentials/
# Local operator overrides and VM disks
/local/
*.local.nix
*.qcow2
*.img
*.vdi
*.vmdk
```

**Caution:** Ignoring `*.img` could hide useful nonsecret test images; intentionally add approved assets if needed. Neglecting file modes, `.gitignore` exclusions, or tracked history can still cause leakage.

## Review before first public push

1. Freeze live changes and obtain an up-to-date source snapshot with authorization to review it.
2. `git status --short`, `git ls-files`, inspect all untracked and ignored files locally (`git status --ignored --short`). Do not paste secret-bearing output.
3. Remove editor backup, obsolete adapter and stale host-specific lab aliases; verify no imports refer to removed paths.
4. Scan all new files and shell scripts; separately inspect LUKS, hardware configuration, user account permissions, system imports and networking. Use a secret scanner such as `gitleaks` on proposed publication files and audit findings manually.
5. Keep the *working private* hardware config under local management; publish a clearly marked placeholder/example or consciously decide what nonsecret identifiers may be public.
6. Create a separate publication directory **without copying `.git`**. Never run `git init` inside the original working repository just to erase history.
7. Review `git diff --cached`, `git ls-files`, `git status --ignored` and secret-scan results in the **new** repository before its first commit.
8. Create a private GitHub repo initially. Upload only reviewed history. Publicize only after one more check and approval.
9. Back up files securely; do not expect an ignored secret to be encrypted or protected by Git.

## Known uncertainties

- Current archive is not necessarily the active system.
- Scan does not establish the absence of embedded secrets, proprietary dependencies or insecure runtime behavior.
- Host claims about encryption/software freedom are not remote attestation.
- No automated verification of VM guest firewall, firmware, disk unlock, or graphical login has been performed by this document package.
