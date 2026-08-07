# nixos-config

Personal NixOS Unstable workstation config.

i5-13400F · 32 GB RAM · AMD RX 9060 XT · Samsung 990 PRO 2TB · KDE Plasma 6

## Fresh install

Boot a NixOS 26.11pre minimal ISO with internet access and run:

```bash
curl -fL https://nixos.byetgin.com/install.sh|sudo bash
```

The installer verifies the exact Samsung 990 PRO by stable by-id + serial, builds the locked system first, then automatically formats that system disk and installs NixOS. The 1TB NVMe and 480GB SATA data disks are not installer targets. The `byetgin` password is requested at the end.

If the repository already contains a committed `flake.lock`, reinstall uses that exact known-good lock. If no lock exists yet, the first install creates one.

## After first boot

The real config repository is:

```text
~/Desktop/nixos-config
```

`/etc/nixos` is a symlink to the same repository.

### SMB credentials

The SMB shares use the local username `Yakrel`. Keep the password out of Git by creating the root-only credentials file once after a fresh install:

```fish
sudo install -d -m 700 /etc/samba
read -s -P "SMB password for Yakrel: " SMB_PASS
echo
printf 'username=Yakrel\npassword=%s\n' "$SMB_PASS" | sudo tee /etc/samba/homelab.credentials >/dev/null
set -e SMB_PASS
sudo chmod 600 /etc/samba/homelab.credentials
```

The configured shares are:

```text
/data/datapool        -> //192.168.1.102/datapool
/data/fastpool-config -> //192.168.1.102/fastpool-config
```

### Save the first known-good lock

After confirming the desktop works:

```bash
cd ~/Desktop/nixos-config
git status
git add flake.lock
git commit -m "chore: save initial flake lock (YYYY-MM-DD)"
git push
```

### Save a clean /home baseline

```bash
sudo snapper -c home create --description "Fresh NixOS baseline"
sudo snapper -c home list
```

## Normal use

Config/code changed on GitHub:

```bash
cd ~/Desktop/nixos-config
git pull
nixapply
```

Local config changed, such as adding/removing a package or changing KDE settings:

```bash
nixapply
```

`nixapply` uses the current `flake.lock`; it does not intentionally advance package/input revisions.

## Rolling update

To advance nixpkgs, Home Manager, Disko and NUR to newer revisions:

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

If an update is bad, boot the previous NixOS generation from systemd-boot and restore the committed lock before rebuilding:

```bash
git -C ~/Desktop/nixos-config restore flake.lock
```

## Useful checks

```bash
sudo snapper -c home list
systemctl --failed
lspci -nnk
nixos-version
uname -r
```

`flake.lock` is the exact input snapshot used by NixOS. Keep a working lock committed; a later fresh install will reuse the latest committed known-good lock instead of silently jumping to whatever `nixos-unstable` happens to contain that day.
