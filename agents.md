## Rules
- Never `git commit` or `git push` without explicit user approval
- Never put credentials or secrets in the repository
- Never target an install disk by volatile names such as `/dev/nvme0n1`; use the verified stable by-id path
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
- Fresh install may run `nix flake lock` only to ensure a lock exists. If no lock exists yet, this resolves the current inputs and creates the initial snapshot; if a committed lock already exists, do not advance its existing revisions during bootstrap.
- During fresh install, create the target checkout's lock with the live ISO's working Nix, not a normal-user Nix invocation inside `nixos-enter`; the target nix-daemon is not running yet.
- Until a newly created `flake.lock` is tracked by Git, an ordinary raw Git flake path may ignore it. The installer's first locked build must therefore use an explicit `path:/home/byetgin/Desktop/nixos-config#nixos` reference (or otherwise ensure the lock is indexed) so the new lock is actually included.
- The installer must not automatically stage, commit or push `flake.lock`; the user saves the checkpoint only after verifying a successful boot.
- After the first successful boot, commit and push the initial `flake.lock` as the first known-good checkpoint.
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
