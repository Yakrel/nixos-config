## Rules
- Never `git commit` or `git push` without explicit user approval

## Intent
- Rolling release (arch-like): nixos-unstable channel, NUR fetched from `main` — intentional, no sha256 pin
- Flakes are not wanted — they lock versions, opposing the rolling goal
