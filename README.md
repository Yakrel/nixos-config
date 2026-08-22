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

Save the first working lock after install:

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

## Daily workflow & commands

```bash
# Configuration & package management
nh os switch                                    # Build and activate the current configuration
nh os test                                      # Test configuration changes ephemerally (resets on reboot)
nh search <package>                             # Search packages across Nixpkgs with formatted output
nix run nixpkgs#<package>                       # Run a program ephemerally without installing it to the system

# Rolling upgrade (update packages)
git pull
nix flake update                                # Update all declared flake inputs to newest versions
nh os boot                                      # Build and register the new system generation for next boot
reboot

# System inspection & snapshots
nvd diff /run/booted-system /run/current-system # Show package differences between running and target generations
sudo nixos-rebuild list-generations             # List all historical system generations
snapper -c home list                            # List Btrfs snapshots for /home
```

After verifying a new boot generation works properly:

```bash
cd ~/Desktop/nixos-config
git add flake.lock
git commit -m "chore: update flake inputs ($(date +%F))"
git push
```
