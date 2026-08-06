## Rules
- Never `git commit` or `git push` without explicit user approval

## Goal
- Rolling release, arch/yay style: every `nixupdate` pulls the latest packages, no pin
- Flake exists not for version locking — required for single-command install via disko
- NUR pulled from main branch, no sha256 pin — intentional

## Version
- `nixosVersion` is defined once in `flake.nix` → consumed by configuration.nix + home.nix
- On a fresh install with a new ISO: only change `nixosVersion` in `flake.nix`
