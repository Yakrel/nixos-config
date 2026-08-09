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

Authenticate GitHub CLI once:

```bash
gh auth login
```

Home Manager already configures Git to use the GitHub CLI credential helper over HTTPS, so `git fetch`, `git pull` and `git push` use that login without a separate SSH key or `gh auth setup-git` step.

Brave account/session state stays intentionally mutable. Enable Brave Sync from the browser when wanted. Bitwarden and the JDownloader Download Interceptor are installed by the Nix configuration; other synced extensions can come from Brave Sync.

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

`nixupdate` advances all declared flake inputs together. This includes `Yakrel/jdownloader-download-interceptor`, so after pushing a new revision of that extension to its `main` branch, the next `nixupdate` pins and builds the new revision for Brave.

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

## Useful checks

```bash
snapper -c home list
systemctl --failed
lspci -nnk
nixos-version
uname -r
```

A later fresh install reuses the latest committed known-good `flake.lock`; only `nixupdate` intentionally moves it forward.
