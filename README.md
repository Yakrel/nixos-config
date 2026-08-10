# nixos-config

Personal NixOS Unstable workstation config.

i5-13400F · 32 GB RAM · AMD RX 9060 XT · Samsung 990 PRO 2TB · KDE Plasma 6

## Fresh install

Boot the NixOS minimal ISO, get online, then run:

```bash
curl -fL https://nixos.byetgin.com/install.sh | sudo bash
```

The installer clones this public repository into a temporary writable checkout, creates `flake.lock` only if the repository does not already contain one, verifies the exact Samsung install disk by stable by-id + serial, builds Disko and the complete locked system before erasing anything, and installs that already-built closure.

If the repository already contains a committed `flake.lock`, reinstall uses that exact known-good lock. If `nix flake lock` would modify it, installation aborts before disk changes.

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
git add flake.lock
git commit -m "chore: save initial flake lock"
git push
```

Take a manual Snapper baseline for `/home` after the first successful boot:

```bash
sudo snapper -c home create --description "baseline after fresh install"
```

## Apply config changes

After editing Nix files without intentionally updating package/input revisions:

```bash
nixapply
```

This applies the current config using the existing `flake.lock` and shows the generation diff.

## Rolling update

Use a clean Git working tree, then:

```bash
git pull
nixupdate
reboot
```

`nixupdate` advances all declared flake inputs together. This includes the Jellium Desktop `main` nightly AppImage and `Yakrel/jdownloader-download-interceptor`; each update is pinned by `flake.lock` before the system rebuild.

After the new generation boots and works correctly:

```bash
cd ~/Desktop/nixos-config
git status
git add flake.lock
git commit -m "chore: update flake inputs ($(date +%F))"
git push
```

If the new generation is bad, choose the previous generation in the boot menu and restore the previous committed `flake.lock` before rebuilding.

## Useful commands

```bash
nvd diff /run/booted-system /run/current-system
sudo nixos-rebuild list-generations
snapper -c home list
```

## Post-install notes

### Jellium video stutter on high-refresh displays

If 23.976 FPS playback shows periodic micro-stutter or frame drops on a high-refresh display (for example 144 Hz), try mpv's display-resample sync mode. Jellium explicitly loads a per-user mpv config from:

```text
~/.config/jellium-desktop/mpv/mpv.conf
```

Add:

```conf
video-sync=display-resample
```

Keep this as a troubleshooting tweak rather than a mandatory default; if Jellium plays smoothly without it, no change is needed.
