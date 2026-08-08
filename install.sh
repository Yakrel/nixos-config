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
PASSWORD_SECRET="$WORK_DIR/bootstrap/linux-password.age"
PASSWORD_HASH=""

cleanup() {
  unset PASSWORD_HASH
  rm -rf "$WORK_ROOT"
}
trap cleanup EXIT

nix_cmd() {
  nix --extra-experimental-features "nix-command flakes" "$@"
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
BOOTSTRAP_TOOLS="$(nix_cmd build --no-link --print-out-paths "${LOCAL_FLAKE}#bootstrap-tools")"
AGE_BIN="$BOOTSTRAP_TOOLS/bin/age"

echo
echo "Locked install artifacts are ready."
echo "Disko:  $DISKO_SCRIPT"
echo "System: $SYSTEM_PATH"

echo "==> [4/8] Unlocking the fresh-install password bootstrap..."
if [[ ! -f "$PASSWORD_SECRET" ]]; then
  echo
  echo "ERROR: Missing bootstrap/linux-password.age."
  echo "Generate and commit the encrypted password hash before a fresh install."
  echo "No disk changes were made."
  exit 1
fi

# age reads the passphrase interactively from the controlling terminal. Only
# the already-hashed Linux password is decrypted; the plaintext login password
# is never stored in this repository or passed to the installer.
if ! PASSWORD_HASH="$("$AGE_BIN" --decrypt "$PASSWORD_SECRET" </dev/tty)"; then
  echo
  echo "ERROR: Could not decrypt bootstrap/linux-password.age."
  echo "No disk changes were made."
  exit 1
fi

# The helper intentionally generates yescrypt hashes. Reject malformed or
# multi-line decrypted content before any destructive disk operation.
if [[ -z "$PASSWORD_HASH" || "$PASSWORD_HASH" == *$'\n'* || "$PASSWORD_HASH" != \$y\$* ]]; then
  echo
  echo "ERROR: The decrypted bootstrap secret is not a single yescrypt password hash."
  echo "No disk changes were made."
  exit 1
fi

echo "Password bootstrap unlocked and validated."
echo
echo "Verified target: $INSTALL_DISK ($ACTUAL_MODEL, serial $ACTUAL_SERIAL)"
echo "Beginning automatic erase/install; no additional disk confirmation is requested."

echo "==> [5/8] Formatting and mounting the verified system disk..."
bash "$DISKO_SCRIPT"

echo "==> [6/8] Installing the prebuilt locked NixOS system..."
nixos-install --no-root-passwd --system "$SYSTEM_PATH"

echo "==> [7/8] Installing the exact Git checkout used for this install..."
install -d -m 0755 "/mnt/home/byetgin/Desktop"
rm -rf "/mnt$CONFIG_DIR"
cp -a "$WORK_DIR" "/mnt$CONFIG_DIR"

rm -rf /mnt/etc/nixos
ln -s "$CONFIG_DIR" /mnt/etc/nixos

# The checkout was cloned by root on the live ISO; make the real working copy user-owned.
nixos-enter --root /mnt -c 'chown -R byetgin:users /home/byetgin/Desktop/nixos-config'

echo "==> [8/8] Applying the bootstrapped password for user byetgin..."
# Feed only the encrypted-password hash through stdin so it never appears in a
# process argument. chpasswd -e writes the supplied hash directly to shadow.
printf 'byetgin:%s\n' "$PASSWORD_HASH" | nixos-enter --root /mnt -c 'chpasswd -e'
unset PASSWORD_HASH

echo
echo "Done. Reboot when ready."
echo "Config repo: $CONFIG_DIR (owned by byetgin)"
echo "/etc/nixos -> $CONFIG_DIR"
echo "The installed checkout contains the exact flake.lock used for this installation."
echo "The age bootstrap was used only by the live installer; age is not installed in the target system."
echo "After a successful boot, review git status and commit/push flake.lock if it is new."
