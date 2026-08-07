# nixos-config

Personal NixOS Unstable workstation config.

i5-13400F · 32 GB RAM · AMD RX 9060 XT · Samsung 990 PRO 2TB · KDE Plasma 6

## Fresh install

Boot a NixOS 26.11pre minimal ISO with internet access and run:

```bash
curl -fL https://nixos.byetgin.com/install.sh|sudo bash
```

The installer verifies the exact Samsung 990 PRO by stable by-id + serial, builds the locked system first, then automatically formats only that system disk. The 1TB NVMe and 480GB SATA data disks are not installer targets. The `byetgin` password is requested at the end.

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
