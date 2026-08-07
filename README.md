# nixos-config

Rolling-release NixOS with an Arch/yay-style update workflow, while keeping NixOS generations and declarative configuration for rollback.  
i5-13400F · 32 GB RAM · AMD RX 9060 XT · Samsung 990 PRO 2TB · NixOS Unstable · KDE Plasma 6

## Commands

```bash
nixupdate   # update flake inputs + create next boot generation + show diff
nixswitch   # rebuild current locked config immediately
```

`nixupdate` intentionally uses `nixos-rebuild boot`, not `switch`. Kernel, Mesa and desktop updates become active after reboot, so the currently running desktop is not replaced underneath the session.

## Fresh Install

Use a 26.11pre NixOS minimal unstable ISO. `system.stateVersion` / `home.stateVersion` stay at `26.11`; the exact ISO build number is not a stateVersion.

```bash
curl -fL https://nixos.byetgin.com/install.sh|sudo bash
```

The repository is public, so the live ISO does not need Git, a GitHub login, or a token. Nix fetches and evaluates the remote flake directly before any destructive step.

The installer then:

1. verifies the exact Samsung 990 PRO by stable `/dev/disk/by-id` + serial,
2. requires typing `ERASE` through `/dev/tty`,
3. formats only the verified 2TB system disk,
4. installs NixOS,
5. uses Git from the installed target system to clone this repo directly to `~/Desktop/nixos-config`,
6. runs `nix flake lock` to create any missing lock entries without advancing an existing lock,
7. stages `flake.lock` if it was newly created/changed,
8. links `/etc/nixos` to the Desktop Git checkout and builds the first boot generation from that lock,
9. asks for the `byetgin` password.

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

## Config layout

There is one real editable Git checkout:

```text
/home/byetgin/Desktop/nixos-config
```

The installer creates one symlink:

```text
/etc/nixos -> /home/byetgin/Desktop/nixos-config
```

So editing through `/etc/nixos` or `~/Desktop/nixos-config` changes the exact same files. There is no second configuration copy to keep in sync and no extra canonical directory hidden under `~/.config`.

Normal config work:

```bash
cd ~/Desktop/nixos-config
git pull
nixswitch
```

Because `/etc/nixos` is only a symlink, a `git pull` from either path updates the same repository. You never need to pull twice.

Use `nixupdate` when you also want to advance the rolling package/input versions.

## flake.lock and rolling updates

`flake.nix` follows rolling inputs such as `nixos-unstable`; `flake.lock` records the exact revisions currently selected. Keeping `flake.lock` in Git does **not** stop rolling updates — `nixupdate` advances it whenever you choose to update.

On a brand-new repo with no lock file, the installer runs:

```bash
nix flake lock
```

This creates the initial lock from the currently resolvable inputs. It is not the normal rolling-update command. If a committed `flake.lock` already exists, `nix flake lock` keeps existing locked revisions and only fills missing entries. Actual version advancement remains explicit through `nixupdate` (`nix flake update`).

After the first successful boot, save the known-good checkpoint if `flake.lock` is staged:

```bash
cd ~/Desktop/nixos-config
git commit -m "lock working system"
git push
```

Later:

```text
nixupdate
  -> flake.lock advances
  -> new NixOS boot generation is built
  -> reboot into the new generation
  -> if everything works, commit flake.lock
```

If a new generation is bad, choose the previous NixOS generation in systemd-boot. If the bad `flake.lock` was not committed yet, restore it with Git before rebuilding.

Nix GC retains unreachable store paths for 30 days to leave a larger rollback window.

## Desktop policy

Plasma stays functional but duplicate applications are excluded where another chosen application already covers the job:

```text
Terminal    Kitty + Fish     (no Konsole, no xterm, no Alacritty)
Editor      VS Code          (no Kate)
PDF         Brave            (no Okular)
Packages    Nix config       (no Discover)
Mail        Thunderbird      (KDE PIM/Akonadi disabled)
Media       Jellyfin/Brave   (no Elisa)
```

Breeze Dark is written directly to KDE's config from Home Manager without an extra Plasma configuration framework. Night Light is enabled in automatic sunset-to-sunrise mode with KDE/GeoClue.

## Terminal

The terminal stack is intentionally small and close to the CachyOS experience:

```text
Kitty
Fish
Pure prompt
Eza
Bat
Zoxide
JetBrains Mono Nerd Font
```

CachyOS's Fish configuration uses Pure for the clean two-line `directory + git branch` / `❯` prompt, so this config uses the Nixpkgs `fishPlugins.pure` package instead of Starship.

Git and GitHub CLI are both installed system-wide. Home Manager manages the user's Git settings without installing a second Git package.

## Notes

**`@snapshots` subvolume** — `/home/.snapshots` is separate so Snapper snapshots do not recursively contain themselves.

**`stateVersion`** — defined once in `flake.nix` as `nixosVersion`. It is a compatibility setting, not the package/version snapshot. Do not raise it on normal rolling updates.
