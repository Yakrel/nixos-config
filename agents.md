## Rules
- Never `git commit` or `git push` without explicit user approval
- Never put credentials or secrets in the repository
- Never target an install disk by volatile names such as `/dev/nvme0n1`; use the verified stable by-id path

## Goal
- Rolling release, Arch/yay style: `nixupdate` intentionally advances the rolling flake inputs
- Keep `flake.lock` in Git so every known-good package/input set is reproducible
- `nixupdate` builds a new boot generation; it must not replace the running graphics/kernel stack with `switch`
- NUR follows its flake input and is advanced together with the other inputs

## Config layout
- The only real editable Git checkout is `/home/byetgin/Desktop/nixos-config`
- `/etc/nixos` is a symlink to that checkout; never maintain a second config copy

## Rollback model
- NixOS generations recover the operating-system generation
- Git + `flake.lock` recover the exact declarative input revisions
- Snapper protects `/home` user data independently
- GC keeps unreachable store paths for 30 days

## Version
- `nixosVersion` is defined once in `flake.nix` and consumed by configuration.nix + home.nix
- `stateVersion` is compatibility state, not the rolling package version
- A fresh 26.11pre installation uses `nixosVersion = "26.11"`; normal rolling updates do not change it
