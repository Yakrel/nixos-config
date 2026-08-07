#!/usr/bin/env bash
# nixos.byetgin.com/install.sh
# Run from a NixOS 26.11pre minimal ISO:
#   curl -fL https://nixos.byetgin.com/install.sh|sudo bash
set -euo pipefail

FLAKE_URI="github:Yakrel/nixos-config"
FLAKE_CONFIG="${FLAKE_URI}#nixos"
INSTALL_DISK_BY_ID="/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_2TB_S7DRNJ0Y104863E"
EXPECTED_SERIAL="S7DRNJ0Y104863E"

nix_cmd() {
  nix --extra-experimental-features "nix-command flakes" "$@"
}

echo "==> [1/6] Checking installer target..."
if [[ ! -e "$INSTALL_DISK_BY_ID" ]]; then
  echo "ERROR: Expected Samsung 990 PRO was not found at:"
  echo "  $INSTALL_DISK_BY_ID"
  echo
  echo "Detected disks:"
  lsblk -d -o NAME,SIZE,MODEL,SERIAL
  exit 1
fi

INSTALL_DISK="$(readlink -f "$INSTALL_DISK_BY_ID")"
ACTUAL_SERIAL="$(lsblk -dn -o SERIAL "$INSTALL_DISK" | xargs)"
ACTUAL_MODEL="$(lsblk -dn -o MODEL "$INSTALL_DISK" | xargs)"
ACTUAL_SIZE="$(lsblk -dn -o SIZE "$INSTALL_DISK" | xargs)"

if [[ "$ACTUAL_SERIAL" != "$EXPECTED_SERIAL" ]]; then
  echo "ERROR: Disk serial mismatch. Refusing to continue."
  echo "Expected: $EXPECTED_SERIAL"
  echo "Found:    $ACTUAL_SERIAL"
  exit 1
fi

echo "Target disk: $INSTALL_DISK"
echo "Model:       $ACTUAL_MODEL"
echo "Serial:      $ACTUAL_SERIAL"
echo "Size:        $ACTUAL_SIZE"
echo

echo "==> [2/6] Validating remote flake before touching the disk..."
if ! nix_cmd eval --raw "${FLAKE_URI}#nixosConfigurations.nixos.config.system.build.toplevel.drvPath" >/dev/null; then
  echo
  echo "ERROR: The NixOS flake could not be fetched/evaluated."
  echo "No disk changes were made. Check network access and the flake configuration."
  exit 1
fi

echo
printf '%s\n' \
  "WARNING: THE FOLLOWING DISK WILL BE COMPLETELY ERASED:" \
  "  $INSTALL_DISK" \
  "  $ACTUAL_MODEL" \
  "  Serial: $ACTUAL_SERIAL" \
  "" \
  "The 1TB NVMe and 480GB SATA data disks are NOT installer targets." \
  "Type ERASE to continue:"
read -r confirmation </dev/tty
if [[ "$confirmation" != "ERASE" ]]; then
  echo "Cancelled. No disk changes were made."
  exit 1
fi

echo "==> [3/6] Formatting the verified system disk with disko..."
nix_cmd run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --flake "$FLAKE_CONFIG"

echo "==> [4/6] Installing NixOS..."
nixos-install --no-root-passwd --flake "$FLAKE_CONFIG"

echo "==> [5/6] Preparing the canonical config path..."
rm -rf /mnt/etc/nixos
ln -s /home/byetgin/Desktop/nixos-config /mnt/etc/nixos

echo "==> [6/6] Setting password for user byetgin..."
nixos-enter --root /mnt -c 'passwd byetgin'

echo
echo "Done. Reboot, log in, then clone the repo to ~/Desktop/nixos-config."
