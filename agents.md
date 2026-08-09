## Rules
- Never `git commit` or `git push` without explicit user approval
- Never put credentials, SMB usernames, passwords or other secrets in the repository
- Prefer typed, declarative NixOS/Home Manager/plasma-manager options for system and desktop configuration. Use declarative package overrides or browser policies when no higher-level module option exists. Do not mutate live user configuration with ad-hoc shell/Python scripts, manual file copies, or post-install commands when a supported declarative option exists; keep activation/runtime scripting as a documented last resort only when the target application has no suitable declarative interface.
- Use KDE/Dolphin KIO (`smb://...`) for the homelab shares by default; seed `datapool` and `fastpool-config` into Dolphin Places while preserving the user's mutable `user-places.xbel`; do not add system-level CIFS mounts or credential files unless the user explicitly asks for them
- Keep README operational and concise: install, first-boot, update, rollback and essential commands; do not duplicate implementation details already clear from the Nix code
- Never target an install disk by volatile names such as `/dev/nvme0n1`; use the verified stable by-id path
- Keep the destructive install target single-source: `disko.devices.disk.main.device` in `disko.nix` is authoritative, and `install.sh` must evaluate that value rather than duplicating the device path. Keep the serial check independent so an accidental target change aborts safely.
- Keep the system GPT partition labels explicit as `nixos-boot` and `nixos-root`; do not rely on Disko's generated `disk-main-*` defaults
- Never run `nix flake update` implicitly as part of an unrelated config change; advancing input revisions must be an explicit rolling-update action

## Goal
- Rolling release, Arch/yay style: `nixupdate` intentionally advances the rolling flake inputs
- Keep `flake.lock` in Git so every known-good package/input set is reproducible
- `nixupdate` builds a new boot generation; it must not replace the running graphics/kernel stack with `switch`
- NUR follows its flake input and is advanced together with the other inputs

## Daily workflow
- Use normal Git commands for repository synchronization; do not invent a `nixpull` alias or hide Git operations behind Nix-named aliases
- `nixapply`: rebuild/apply the current configuration using the existing `flake.lock`; use this after adding/removing packages, changing KDE/Home Manager settings, services, mounts, aliases, etc.
- `nixupdate`: intentionally advance flake inputs (`nix flake update`) and build the next boot generation; this is the command that normally changes `flake.lock`
- Prefer a clean Git working tree before `git pull`; local work may be committed without being pushed first, but do not discard or overwrite local changes automatically

## flake.lock policy
- Fresh install uses the Git already available on the NixOS minimal live ISO to clone the public repository into a writable temporary directory before any destructive disk operation.
- If the repository has no committed `flake.lock`, run `nix flake lock` there to create the initial snapshot.
- If a committed `flake.lock` already exists, bootstrap may run `nix flake lock` only as a consistency check; if the file changes at all, abort before touching the disk. A reinstall must use the last committed known-good lock exactly, never silently advance or repair it.
- Use an explicit `path:` flake reference for the temporary checkout so a newly created, still-untracked initial `flake.lock` is included by Nix.
- Resolve the destructive install target from `nixosConfigurations.nixos.config.disko.devices.disk.main.device` in that exact locked checkout, require a stable `/dev/disk/by-id/...` path, and verify the independent expected serial before running Disko.
- Evaluate and build both `config.system.build.diskoScript` and `config.system.build.toplevel` from that exact locked checkout before modifying the disk. Configuration/fetch/build failures must happen first.
- The installer intentionally has no extra `ERASE` confirmation once the exact Samsung by-id + serial has been verified and the locked artifacts have built successfully.
- Run the built `system.build.diskoScript` instead of fetching a separate latest Disko CLI, so disk formatting uses the same locked Disko module revision as the NixOS configuration.
- Install the already-built system closure with `nixos-install --system`; do not re-resolve the flake after the disk has been erased.
- After installation, copy that exact temporary Git checkout, including `.git` and its `flake.lock`, to `/home/byetgin/Desktop/nixos-config`, then make it owned by `byetgin:users`. Do not clone or lock a second time.
- When `install.sh` is piped from curl, attach the final `passwd byetgin` call to `/dev/tty` so it reads the real keyboard rather than the pipe.
- The installer must not automatically stage, commit or push `flake.lock`; the user saves the checkpoint only after verifying a successful boot.
- After the first successful boot, commit and push the initial `flake.lock` as the first known-good checkpoint, then take a manual `/home` Snapper baseline.
- After every intentional `nixupdate`, reboot into the new generation and verify the system before committing the changed `flake.lock`.
- If the new generation is good, commit the lock update. Preferred commit message: `chore: update flake inputs (YYYY-MM-DD)`.
- Do not invent a manual sequential revision number. Git commit hashes already provide immutable revision identity; the date in the commit message is only for readability.
- If the new generation is bad, boot the previous NixOS generation and restore the previous committed `flake.lock` before rebuilding.

## Config layout
- The only real editable Git checkout is `/home/byetgin/Desktop/nixos-config`
- `/etc/nixos` is a symlink to that checkout; never maintain a second config copy
- The real checkout must remain owned by `byetgin`; `/etc/nixos` itself may be a root-owned symlink without requiring sudo for editing the user-owned target files

## Rollback model
- NixOS generations recover the operating-system generation
- Git + `flake.lock` recover the exact declarative input revisions
- Snapper protects `/home` user data independently
- GC keeps unreachable store paths for 30 days

## Version
- `nixosVersion` is defined once in `flake.nix` and consumed by configuration.nix + home.nix
- `stateVersion` is compatibility state, not the rolling package version
- A fresh 26.11pre installation uses `nixosVersion = "26.11"`; normal rolling updates do not change it
