# nixos-config

Personal NixOS Unstable workstation config.

i5-13400F · 32 GB RAM · AMD RX 9060 XT · Samsung 990 PRO 2TB · KDE Plasma 6

## Fresh install

Boot a NixOS 26.11pre minimal ISO with internet access and run:

```bash
curl -fL https://nixos.byetgin.com/install.sh|sudo bash
```

The installer verifies the exact Samsung 990 PRO by stable by-id + serial, builds the locked system first, then automatically formats only that system disk. It asks for the `byetgin` password and local SMB username/password at the end. SMB credentials are written root-only under `/etc/samba`; they are never stored in Git.

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
sudo snapper -c home create --description "Fresh NixOS baseline"
sudo snapper -c home list
```

## Normal use

Config changed on GitHub:

```bash
cd ~/Desktop/nixos-config
git pull
nixapply
```

Local config changed (package/KDE/service/mount/etc.):

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

## Change SMB credentials

```fish
sudo install -d -m 700 /etc/samba
read -P "SMB username: " SMB_USER
read -s -P "SMB password: " SMB_PASS
echo
printf 'username=%s\npassword=%s\n' "$SMB_USER" "$SMB_PASS" | sudo tee /etc/samba/homelab.credentials >/dev/null
set -e SMB_USER SMB_PASS
sudo chmod 600 /etc/samba/homelab.credentials
```

Shares:

```text
/data/datapool        -> //192.168.1.102/datapool
/data/fastpool-config -> //192.168.1.102/fastpool-config
```

## Useful checks

```bash
sudo snapper -c home list
systemctl --failed
lspci -nnk
nixos-version
uname -r
```

A later fresh install reuses the latest committed known-good `flake.lock`; only `nixupdate` intentionally moves it forward.
