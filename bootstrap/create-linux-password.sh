#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="$SCRIPT_DIR/linux-password.age"
TMP_OUTPUT="$(mktemp "${TMPDIR:-/tmp}/linux-password.age.XXXXXX")"
LINUX_PASSWORD=""
LINUX_PASSWORD_CONFIRM=""
PASSWORD_HASH=""

cleanup() {
  unset LINUX_PASSWORD LINUX_PASSWORD_CONFIRM PASSWORD_HASH
  rm -f "$TMP_OUTPUT"
}
trap cleanup EXIT

for command in age mkpasswd; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "ERROR: $command is not available." >&2
    echo "Run this helper through: nix shell nixpkgs#age nixpkgs#whois -c bash ./bootstrap/create-linux-password.sh" >&2
    exit 1
  fi
done

printf 'Linux login password: ' >/dev/tty
IFS= read -r -s LINUX_PASSWORD </dev/tty
printf '\nConfirm Linux login password: ' >/dev/tty
IFS= read -r -s LINUX_PASSWORD_CONFIRM </dev/tty
printf '\n' >/dev/tty

if [[ -z "$LINUX_PASSWORD" ]]; then
  echo "ERROR: Linux login password must not be empty." >&2
  exit 1
fi

if [[ "$LINUX_PASSWORD" != "$LINUX_PASSWORD_CONFIRM" ]]; then
  echo "ERROR: Linux login passwords do not match." >&2
  exit 1
fi

PASSWORD_HASH="$(printf '%s\n' "$LINUX_PASSWORD" | mkpasswd -m yescrypt --stdin)"
unset LINUX_PASSWORD LINUX_PASSWORD_CONFIRM

if [[ "$PASSWORD_HASH" != \$y\$* || "$PASSWORD_HASH" == *$'\n'* ]]; then
  echo "ERROR: mkpasswd did not produce a single yescrypt hash." >&2
  exit 1
fi

if [[ -e "$OUTPUT" ]]; then
  printf 'Replace existing %s? [y/N] ' "$OUTPUT" >/dev/tty
  IFS= read -r answer </dev/tty
  case "$answer" in
    y|Y|yes|YES) ;;
    *) echo "Cancelled."; exit 1 ;;
  esac
fi

echo "Encrypting the password hash with your bootstrap master passphrase..."
printf '%s\n' "$PASSWORD_HASH" | age --passphrase --output "$TMP_OUTPUT"
unset PASSWORD_HASH

chmod 0600 "$TMP_OUTPUT"
mv -f "$TMP_OUTPUT" "$OUTPUT"
trap - EXIT

echo "Created: $OUTPUT"
echo "Only this .age ciphertext may be committed; never commit the Linux password or master passphrase."
