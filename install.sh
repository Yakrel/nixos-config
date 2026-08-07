#!/usr/bin/env bash
# nixos.byetgin.com/install.sh
# Run from a NixOS minimal unstable ISO:
#   curl -fsSL https://nixos.byetgin.com/install.sh | sudo bash
set -euo pipefail

FLAKE="github:Yakrel/nixos-config#nixos"
INSTALL_DISK_BY_ID="/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_2TB_S7DRNJ0Y104863E"
EXPECTED_SERIAL="S7DRNJ0Y104863E"

nix_cmd() {
  nix --extra-experimental-features "nix-command flakes" "$@"
}

echo "==> [1/5] Checking installer target..."
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

echo "==> [2/5] Validating remote flake before touching the disk..."
if ! nix_cmd eval --raw "$FLAKE#nixosConfigurations.nixos.config.system.build.toplevel.drvPath" >/dev/null; then
  echo
  echo "ERROR: The NixOS flake could not be fetched/evaluated."
  echo "No disk changes were made."
  echo "If the GitHub repository is private, make it accessible to Nix or configure a GitHub access token first."
  exit 1
fi

echo
echo=""
printf '%s\n' "WARNING: THE FOLLOWING DISK WILL BE COMPLETELY ERASED:" \
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

echo "==> [3/5] Formatting the verified system disk with disko..."
nix_cmd run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --flake "$FLAKE"

echo "==> [4/5] Installing NixOS..."
nixos-install --no-root-passwd --flake "$FLAKE"

echo "==> [5/5] Setting password for user byetgin..."
nixos-enter --root /mnt -c 'passwd byetgin'

echo
echo=""
echo "Done. Reboot when ready."
