# Mimari Kararlar

Bu dosya konfigürasyonda alınan her kararın gerekçesini içerir.
Kod okunduğunda "neden böyle?" sorusunu cevaplar.

---

## Flake var, ama rolling release devam ediyor

"Flake = sürüm kilidi = rolling değil" yaygın bir yanlış inanç.

- **Channel** ile: `nix-channel --update` her seferinde kontrolsüz en son paketi çeker.
- **Flake** ile: `nix flake update` çalıştırınca `flake.lock` güncellenir — sen istediğinde.

Sonuç aynı: istediğin zaman güncelle, istediğin zaman durdur. Flake sana daha fazla kontrol verir, daha az değil.

Flake'i seçmemizin asıl sebebi: **disko ile tek komutlu kurulum**.
`curl -L nixos.byetgin.com/install.sh | sudo sh` — disk biçimlendirir, sistemi kurar, biter.
Bu olmadan ISO'dan kurulum çok adımlı ve hata yapmaya açık.

---

## Disko

[nix-community/disko](https://github.com/nix-community/disko): disk layout'unu (partition + format + mount) Nix kodu ile tanımlar.

**Sadece sıfırdan kurulumda çalışır** — `nixos-rebuild switch` ile hiçbir etkisi yok.

Kurulum akışı:
1. NixOS minimal unstable ISO'su boot edilir
2. `install.sh` scripti disko komutunu çalıştırır → disk silinir, btrfs subvol'leri oluşturulur, mount edilir
3. `nixos-install --flake github:Yakrel/nixos-config#nixos` çalışır → sistem kurulur

Disk layout `disko.nix`'te tanımlı.

---

## Btrfs subvolume yapısı

```
nvme0n1
├── p1  1G    vfat   /boot
└── p2  kalan btrfs
    ├── @           →  /
    ├── @home       →  /home
    ├── @nix        →  /nix
    └── @snapshots  →  /home/.snapshots
```

**Neden @nix ayrı subvol?**
Snapper `/home` snapshot'ları alırken `/nix/store` (şu an ~12 GB) her snapshot'a kopyalanır. @nix ayrı subvol'de olduğu için snapper onu atlar. Snapshot'lar küçük kalır.

**Neden @snapshots ayrı subvol?**
Snapper'ın `/home/.snapshots` dizininin **btrfs subvolume** olması zorunlu. Klasör olursa snapshot içinde snapshot oluşur, anlamsızlaşır. Önceki kurulumda bu dizin elle oluşturulmuştu — şimdi disko'da tanımlı, kurulumda otomatik gelir.

---

## Swap yok, zRAM var

32 GB RAM olan bir sistemde swap partition gereksiz. Hibernate de kullanılmıyor.

Bunun yerine **zRAM**: RAM içinde sıkıştırılmış blok device. Disk'e yazmaz, çok daha hızlı. CachyOS ve Omarchy'nin default'u aynı.

NixOS'ta tek satır: `zramSwap.enable = true;`

Eski 8.8 GB swap partition disko'nun yeni layout'unda yok. Reinstall'da ortadan kalkar.

---

## home-manager

Kullanıcı seviyesindeki config'i (`~/.config/...`) sistem config'inden ayırır.

**System level'da kalanlar** (root yetkisi gerektirenler):
- Servisler, KDE, audio, hardware, paket kurulumu

**home-manager'a taşınanlar** (kullanıcı dotfile'ları):
- Fish alias'ları ve shell config → `modules/home/fish.nix`
- Git kullanıcı adı/email → `modules/home/git.nix`
- Kitty terminal config → `modules/home/kitty.nix`

Reinstall'da `home-manager switch` ile dotfile'lar da otomatik gelir.

---

## NUR — flake input olarak

Önceki yapı:
```nix
nixpkgs.config.packageOverrides = pkgs: {
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") { ... };
};
```

`builtins.fetchTarball` flake'lerde impure olduğu için çalışmaz.

Yeni yapı: `flake.nix` inputs'una `nur.url = "github:nix-community/NUR"` eklendi.
Overlay olarak uygulanıyor: `{ nixpkgs.overlays = [ nur.overlays.default ]; }`

Paketler eskisi gibi `pkgs.nur.repos.*` ile erişilebilir. NUR hâlâ main branch'ten çekiliyor, pin yok.

---

## nixos.byetgin.com (GitHub Pages)

Install script'i erişilebilir kılmak için:
- `CNAME` dosyası repoda mevcut: `nixos.byetgin.com`
- GitHub Pages: Settings → Pages → main / (root)
- DNS: `CNAME nixos → Yakrel.github.io`

Kurulum komutu: `curl -L nixos.byetgin.com/install.sh | sudo sh`

---

## Neler değerlendirildi ama alınmadı

**nucleus-template** (muhammadtalha-quant): Yapı ilhamı aldık (katman ayrımı), kodu almadık.
`import-tree` bağımlılığı ve çok derin iç içe geçmiş klasör yapısı tek makine için overhead.

**juspay/nixos-unified-template**: macOS + Linux cross-platform geliştirme aracı, bizim hedefimiz değil.
`nixos-unified` + `flake-parts` + autowiring — 3 framework katmanı, içini okumak neredeyse imkansız.

**specialArgs** (nucleus-template'deki pattern): `userName`, `hostName` gibi değişkenleri tüm modüllere akıtmak için kullanılıyor. 3 modüllü tek host yapısında gereksiz overhead. Modül sayısı artarsa eklenebilir.

**Disko için ayrı subvol `@snapshots`**: Snapper'ın `/home/.snapshots`'ı btrfs subvolume olarak beklemesi zorunlu. Bunu disko'ya eklemek sayesinde bir önceki kurulumda elle yapılan adım artık otomatik.
