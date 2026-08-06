## Rules
- Never `git commit` or `git push` without explicit user approval

## Goal
- Rolling release, arch/yay tarzı: her `nixupdate` en son paketleri getirir, pin yok
- Flake var ama versiyon kilitlemek için değil — disko ile tek komutlu kurulum için zorunlu
- NUR main branch'ten çekiliyor, sha256 pin'i yok — intentional

## Version
- `nixosVersion` flake.nix'te tek yerde tanımlı → configuration.nix + home.nix buradan alır
- Yeni ISO ile sıfırdan kurulumda sadece flake.nix'teki `nixosVersion` değiştirilir
