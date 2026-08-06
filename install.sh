#!/usr/bin/env bash
# nixos.byetgin.com/install.sh
# Run from a NixOS minimal unstable ISO:
#   curl -L nixos.byetgin.com/install.sh | sudo sh
set -e

FLAKE="github:Yakrel/nixos-config#nixos"
NIX_FLAGS="--extra-experimental-features 'nix-command flakes'"

echo "==> [1/3] Formatting disk (disko)..."
nix $NIX_FLAGS run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --flake "$FLAKE"

echo "==> [2/3] Installing NixOS..."
nixos-install --no-root-passwd --flake "$FLAKE"

echo "==> [3/3] Setting password for user byetgin..."
nixos-enter --command "passwd byetgin"

echo ""
echo "Done. Run 'reboot' to restart."
