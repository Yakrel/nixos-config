#!/usr/bin/env bash
# nixos.byetgin.com/install.sh
# NixOS minimal unstable ISO'sundan çalıştır:
#   curl -L nixos.byetgin.com/install.sh | sudo sh
set -e

FLAKE="github:Yakrel/nixos-config#nixos"
NIX_FLAGS="--extra-experimental-features 'nix-command flakes'"

echo "==> [1/2] Disk biçimlendiriliyor (disko)..."
nix $NIX_FLAGS run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --flake "$FLAKE"

echo "==> [2/2] NixOS kuruluyor..."
nixos-install --no-root-passwd --flake "$FLAKE"

echo ""
echo "Kurulum tamamlandı. 'reboot' ile yeniden başlatabilirsin."
