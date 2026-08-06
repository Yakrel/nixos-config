# nixos-config

i5-13400F · 32 GB RAM · NixOS Unstable · KDE Plasma 6

## Kararlar

**Rolling release.** nixos-unstable + NUR main, flake.lock ile pin yok — her `nixupdate` en son paketleri getirir. Flake yine de var çünkü disko ile tek komutlu kurulum için zorunlu.

**zRAM, swap partition yok.** 32 GB RAM'de gereksiz. CachyOS ve Omarchy default'u aynı.

**Btrfs subvolumes:** `@` `@home` `@nix` `@snapshots` — `disko.nix`'te tanımlı, kurulumda otomatik oluşur.  
`@nix` ayrı subvol: snapper `/home` snapshot'larına `/nix/store` dahil olmaz.  
`@snapshots` ayrı subvol: `/home/.snapshots` için zorunlu — aksi hâlde snapshot içinde snapshot oluşur.

**`stateVersion`** — ilk kurulum tarihi, güncellenmez. NixOS: `26.11`, home-manager: `25.11`.

## Komutlar

```bash
nixupdate   # flake güncelle + rebuild + değişiklikleri göster
nixswitch   # sadece rebuild (flake güncellemeden)
```

## Sıfırdan Kurulum

```bash
curl -L nixos.byetgin.com/install.sh | sudo sh
```

NixOS minimal unstable ISO'sundan çalıştır. Disk silinir, btrfs subvol'leri oluşturulur, sistem kurulur.

## nixos.byetgin.com kurulumu (GitHub Pages)

1. GitHub: repo Settings → Pages → Source: **main** branch → **/ (root)**
2. Custom domain: `nixos.byetgin.com`
3. DNS kaydı (domain panelinde):
   ```
   CNAME  nixos  →  Yakrel.github.io
   ```
4. `CNAME` dosyası repoda mevcut.
