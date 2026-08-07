# nixos-config

Rolling-release NixOS with an Arch/yay-style update workflow, while keeping NixOS generations and declarative configuration for rollback.  
i5-13400F · 32 GB RAM · AMD RX 9060 XT · Samsung 990 PRO 2TB · NixOS Unstable · KDE Plasma 6

## Commands

```bash
nixupdate   # update flake inputs + create next boot generation + show diff
nixswitch   # rebuild current config immediately without updating inputs
```

`nixupdate` intentionally uses `nixos-rebuild boot`, not `switch`. Kernel, Mesa and desktop updates become active after reboot, so the currently running desktop is not replaced underneath the session.

## Fresh Install

Use a 26.11pre NixOS minimal unstable ISO. `system.stateVersion` / `home.stateVersion` stay at `26.11`; the exact ISO build number is not a stateVersion.

```bash
curl -fsSL https://nixos.byetgin.com/install.sh | sudo bash
```

The installer:

1. verifies the exact Samsung 990 PRO by stable `/dev/disk/by-id` + serial,
2. fetches/evaluates the flake before touching any disk,
3. requires typing `ERASE` through `/dev/tty`,
4. formats only the verified 2TB system disk,
5. installs NixOS and asks for the `byetgin` password.

The existing 1TB NVMe and 480GB SATA Btrfs disks are never disko targets. They are mounted after boot at:

```text
/data/NVMe_1TB
/data/SATA_480G
```

Homelab SMB shares are lazy-mounted so an unavailable server cannot hold up boot:

```text
/data/datapool        -> //192.168.1.102/datapool
/data/fastpool-config -> //192.168.1.102/fastpool-config
```

> The one-line installer references `github:Yakrel/nixos-config`. Nix must be able to access that repository. If the repository is private and no GitHub access token is configured, the installer will stop during preflight **before erasing the disk**.

## flake.lock and rolling updates

`flake.nix` follows rolling inputs such as `nixos-unstable`; `flake.lock` records the exact revisions currently selected. Keeping `flake.lock` in Git does **not** stop rolling updates — `nixupdate` advances it whenever you choose to update.

After the first install/clone, create the initial lock file and commit it:

```bash
nix flake lock
git add flake.lock
git commit -m "lock flake inputs"
```

Normal update flow:

```text
nixupdate
  -> flake.lock advances
  -> new NixOS boot generation is built
  -> reboot into the new generation
  -> if everything works, commit flake.lock
```

If the new generation is bad, choose the previous NixOS generation in systemd-boot. If the bad `flake.lock` was not committed yet, restore it with Git before rebuilding.

Nix GC retains unreachable store paths for 30 days to leave a larger rollback window.

## Notes

**`@snapshots` subvolume** — `/home/.snapshots` is separate so Snapper snapshots do not recursively contain themselves.

**`stateVersion`** — defined once in `flake.nix` as `nixosVersion`. It is a compatibility setting, not the package/version snapshot. Do not raise it on normal rolling updates.
