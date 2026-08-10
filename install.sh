#!/usr/bin/env bash
# nixos.byetgin.com/install.sh
# Run from a NixOS 26.11pre minimal ISO:
#   curl -fL https://nixos.byetgin.com/install.sh|sudo bash
set -euo pipefail

REPO_URL="https://github.com/Yakrel/nixos-config.git"
CONFIG_DIR="/home/byetgin/Desktop/nixos-config"
EXPECTED_SERIAL="S7DRNJ0Y104863E"
WORK_ROOT="$(mktemp -d)"
WORK_DIR="$WORK_ROOT/nixos-config"
LOCAL_FLAKE="path:$WORK_DIR"

cleanup() {
  rm -rf "$WORK_ROOT"
}
trap cleanup EXIT

nix_cmd() {
  nix --extra-experimental-features "nix-command flakes" "$@"
}

storage_diagnostics() {
  echo
  echo "Btrfs device stats:"
  btrfs device stats /mnt || true
  echo
  echo "Recent Btrfs/NVMe kernel messages:"
  journalctl -k --no-pager \
    | grep -Ei 'btrfs|nvme|checksum|corrupt|i/o error|reset|timeout|critical' \
    | tail -200 || true
}

echo "==> [1/8] Cloning and locking the install configuration..."
git clone --quiet "$REPO_URL" "$WORK_DIR"
echo "Config commit: $(git -C "$WORK_DIR" rev-parse --short HEAD)"

LOCK_WAS_COMMITTED=false
if git -C "$WORK_DIR" ls-files --error-unmatch flake.lock >/dev/null 2>&1; then
  LOCK_WAS_COMMITTED=true
  echo "Using the committed flake.lock exactly."
else
  echo "No flake.lock is committed yet; creating the initial lock snapshot."
fi

nix_cmd flake lock "$LOCAL_FLAKE"

if [[ "$LOCK_WAS_COMMITTED" == true ]] && ! git -C "$WORK_DIR" diff --quiet -- flake.lock; then
  echo
  echo "ERROR: The committed flake.lock would change during fresh-install bootstrap."
  echo "Refusing to install an unverified input set. Update and commit flake.lock from a running system first."
  exit 1
fi

echo "==> [2/8] Resolving and checking installer target..."
# Disko is the single source of truth for the destructive target. Keep the
# serial check independent so a mistaken target change fails closed.
INSTALL_DISK_BY_ID="$(nix_cmd eval --raw "${LOCAL_FLAKE}#nixosConfigurations.nixos.config.disko.devices.disk.main.device")"

if [[ "$INSTALL_DISK_BY_ID" != /dev/disk/by-id/* ]]; then
  echo "ERROR: Disko install target must use a stable /dev/disk/by-id path."
  echo "Configured target: $INSTALL_DISK_BY_ID"
  exit 1
fi

if [[ ! -e "$INSTALL_DISK_BY_ID" ]]; then
  echo "ERROR: Configured install disk was not found at:"
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

echo "==> [3/8] Building the exact locked installer artifacts before touching the disk..."
if ! nix_cmd eval --raw "${LOCAL_FLAKE}#nixosConfigurations.nixos.config.system.build.toplevel.drvPath" >/dev/null; then
  echo
  echo "ERROR: The locked NixOS configuration could not be evaluated."
  echo "No disk changes were made."
  exit 1
fi

DISKO_SCRIPT="$(nix_cmd build --no-link --print-out-paths "${LOCAL_FLAKE}#nixosConfigurations.nixos.config.system.build.diskoScript")"
SYSTEM_PATH="$(nix_cmd build --no-link --print-out-paths "${LOCAL_FLAKE}#nixosConfigurations.nixos.config.system.build.toplevel")"

echo
echo "Locked install artifacts are ready."
echo "Disko:  $DISKO_SCRIPT"
echo "System: $SYSTEM_PATH"
echo
echo "Verified target: $INSTALL_DISK ($ACTUAL_MODEL, serial $ACTUAL_SERIAL)"
echo "Beginning automatic erase/install; no additional disk confirmation is requested."

echo "==> [4/8] Formatting and mounting the verified system disk..."
bash "$DISKO_SCRIPT"

echo "==> [5/8] Installing the prebuilt locked NixOS system..."
if nixos-install --no-root-passwd --system "$SYSTEM_PATH"; then
  :
else
  INSTALL_STATUS=$?
  echo
  echo "ERROR: nixos-install failed (status $INSTALL_STATUS)."
  storage_diagnostics
  exit "$INSTALL_STATUS"
fi

echo "==> [6/8] Verifying the installed Btrfs filesystem..."
# Validate every allocated data/metadata block before calling the install good.
# Device counters are persistent, so this also catches corruption/I/O errors
# that occurred earlier in the install even if a later retry happened to work.
btrfs scrub start -Bd /mnt
if ! btrfs device stats -c /mnt; then
  echo
  echo "ERROR: Btrfs recorded device/filesystem errors during installation."
  echo "Refusing to mark this installation as successful."
  storage_diagnostics
  exit 1
fi

echo "Btrfs verification passed with zero device error counters."

echo "==> [7/8] Installing the exact Git checkout used for this install..."
install -d -m 0755 "/mnt/home/byetgin/Desktop"
rm -rf "/mnt$CONFIG_DIR"
cp -a "$WORK_DIR" "/mnt$CONFIG_DIR"

rm -rf /mnt/etc/nixos
ln -s "$CONFIG_DIR" /mnt/etc/nixos

# The checkout was cloned by root on the live ISO; make the real working copy user-owned.
nixos-enter --root /mnt -c 'chown -R byetgin:users /home/byetgin/Desktop/nixos-config'

echo "==> [8/8] Setting password for user byetgin..."
# passwd reads from the live ISO's controlling terminal, so switch that console
# to the same Turkish Q keymap configured for the installed system first.
loadkeys trq
# install.sh is normally executed via `curl | sudo bash`, so stdin is the pipe.
# Explicitly attach passwd to the controlling terminal so it reads the keyboard.
# A typo or mismatch should not abort an otherwise completed installation;
# keep prompting until passwd succeeds.
until nixos-enter --root /mnt -c 'passwd byetgin' </dev/tty; do
  echo
  echo "Password update failed. Please try again."
  echo
done

echo
echo "Done. Reboot when ready."
echo "Config repo: $CONFIG_DIR (owned by byetgin)"
echo "/etc/nixos -> $CONFIG_DIR"
echo "The installed checkout contains the exact flake.lock used for this installation."
echo "After a successful boot, review git status and commit/push flake.lock if it is new."
