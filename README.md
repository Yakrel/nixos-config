# nixos-config

Personal NixOS Unstable workstation config.

i5-13400F · 32 GB RAM · AMD RX 9060 XT · Samsung 990 PRO 2TB · KDE Plasma 6

## Fresh-install password bootstrap

Create or rotate the encrypted Linux login password from a running NixOS checkout:

```bash
nix shell nixpkgs#age nixpkgs#whois -c bash ./bootstrap/create-linux-password.sh
```

The temporary shell provides `age` and `mkpasswd`; neither is installed into the workstation configuration and the command does not create a repo-local flake lock. The helper asks for the Linux login password locally, converts it to a yescrypt hash, then asks for a separate age master passphrase and writes only `bootstrap/linux-password.age`. Commit only that encrypted file; never commit either password or a decrypted hash.

## Fresh install

Boot a NixOS 26.11pre minimal ISO with internet access and run:

```bash
curl -fL https://nixos.byetgin.com/install.sh|sudo bash
```

The installer verifies the exact Samsung 990 PRO by stable by-id + serial, builds the locked system first, then asks for the age master passphrase and validates the decrypted password hash before touching the disk. It automatically formats only that system disk; the 1TB NVMe and 480GB SATA data disks are not installer targets. The validated hash is applied directly to the `byetgin` account after installation.

The age bootstrap is fresh-install-only. `age` is not installed in the target system, and `nixapply` / `nixupdate` do not read or decrypt the bootstrap file.

If the repository already contains a committed `flake.lock`, reinstall uses that exact known-good lock. If no lock exists yet, the first install creates one.

## After first boot

The real config repository is `~/Desktop/nixos-config`; `/etc/nixos` is a symlink to it.

Save the first working lock:

```bash
cd ~/Desktop/nixos-config
git status
git add flake.lock
git commit -m "chore: save initial flake lock (YYYY-MM-DD)"
git push
```

Configure Gemini Dictation once:

```bash
gemini-dikte setup
gemini-dikte doctor
```

Save a clean `/home` baseline:

```bash
snapper -c home create --description "Fresh NixOS baseline"
snapper -c home list
```

## Normal use

Config changed on GitHub:

```bash
cd ~/Desktop/nixos-config
git pull
nixapply
```

Local config changed (package/KDE/service/etc.):

```bash
nixapply
```

`nixapply` uses the current `flake.lock`; it does not advance package/input revisions.

## Rolling update

```bash
nixupdate
reboot
```

After the new generation boots and works correctly:

```bash
cd ~/Desktop/nixos-config
git status
git add flake.lock
git commit -m "chore: update flake inputs (YYYY-MM-DD)"
git push
```

If an update is bad, boot the previous NixOS generation from systemd-boot, then restore the committed lock:

```bash
git -C ~/Desktop/nixos-config restore flake.lock
```

## Network shares

Dolphin Places is seeded with `datapool` and `fastpool-config`. They open through KDE/KIO, so KDE asks for credentials when needed and can remember them in the session/wallet; no SMB username or password is stored in this repository.

```text
smb://192.168.1.102/datapool
smb://192.168.1.102/fastpool-config
```

## Useful checks

```bash
snapper -c home list
systemctl --failed
lspci -nnk
nixos-version
uname -r
```

A later fresh install reuses the latest committed known-good `flake.lock`; only `nixupdate` intentionally moves it forward.
