# nixos-config

Rolling release NixOS — arch/yay style, every update pulls the latest packages.  
i5-13400F · 32 GB RAM · NixOS Unstable · KDE Plasma 6

## Commands

```bash
nixupdate   # update flake + rebuild + show what changed
nixswitch   # rebuild only (without updating the flake)
```

## Fresh Install

From a NixOS minimal unstable ISO:

```bash
curl -L nixos.byetgin.com/install.sh | sudo sh
```

Wipes the disk, creates btrfs subvolumes, installs the system.  
Before running, verify `nixosVersion` in `flake.nix` matches the ISO version.

## Notes

**`@snapshots` subvol is required** — `/home/.snapshots` must be a btrfs subvolume, not a plain directory. Otherwise snapshots nest inside each other and snapper breaks.

**`stateVersion`** — defined once in `flake.nix` (`nixosVersion`). Never change on a running system; only update on a fresh install with a new ISO.
