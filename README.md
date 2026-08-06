# nixos-config

Rolling release NixOS — arch/yay tarzı, her güncellemede en son paketler gelir.  
i5-13400F · 32 GB RAM · NixOS Unstable · KDE Plasma 6

## Komutlar

```bash
nixupdate   # flake güncelle + rebuild + değişiklikleri göster
nixswitch   # sadece rebuild (flake güncellemeden)
```

## Sıfırdan Kurulum

NixOS minimal unstable ISO'sundan:

```bash
curl -L nixos.byetgin.com/install.sh | sudo sh
```

Disk silinir, btrfs subvol'leri oluşturulur, sistem kurulur.  
Kurulumdan önce `flake.nix`'teki `nixosVersion` yeni ISO versiyonuyla eşleşiyor mu kontrol et.

## Notlar

**`@snapshots` subvol zorunlu** — `/home/.snapshots` btrfs subvolume olmalı, klasör olursa snapshot içinde snapshot oluşur, snapper bozulur.

**`stateVersion`** — `flake.nix`'te tek yerde tanımlı (`nixosVersion`). Çalışan sistemde değiştirilmez; sadece yeni ISO ile sıfırdan kurulumda güncellenir.
