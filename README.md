# nixos-config

Rolling-release NixOS with an Arch/yay-style update workflow, while keeping NixOS generations and declarative configuration for rollback.  
i5-13400F · 32 GB RAM · AMD RX 9060 XT · Samsung 990 PRO 2TB · NixOS Unstable · KDE Plasma 6

## Everyday commands

Git stays Git; Nix only needs two helper aliases:

```bash
git pull    # get config/history changes from GitHub
nixapply    # apply the current config exactly as locked
nixupdate   # advance flake.lock to current rolling inputs + build next boot generation
```

The mental model is:

```text
git pull
  GitHub repo changes -> local repo
  this is normal Git; Nix does not resolve newer inputs by itself

nixapply
  current files + current flake.lock -> running system
  use after adding/removing packages, KDE/Home Manager changes, services, mounts, aliases, etc.
  flake.lock is not advanced

nixupdate
  nixpkgs/Home Manager/Disko/NUR -> newer revisions
  flake.lock changes
  new NixOS generation is prepared with `nixos-rebuild boot`
  reboot to activate it
```

Typical config-only change:

```bash
# edit configuration.nix / modules / home config
nixapply
```

If the config changed on GitHub first:

```bash
git pull
nixapply
```

Typical rolling upgrade:

```bash
nixupdate
reboot
```

After a successful reboot, check and save the known-good lock:

```bash
cd ~/Desktop/nixos-config
git status
git add flake.lock
git commit -m "chore: update flake inputs (YYYY-MM-DD)"
git push
```

If the new generation is bad, boot the previous NixOS generation from systemd-boot, then restore the uncommitted lock before trying again:

```bash
git -C ~/Desktop/nixos-config restore flake.lock
```

### Local Git changes before `git pull`

You do not have to push local work before pulling. A push only publishes your commits to GitHub. However, keep the working tree clean before pulling when possible:

```bash
git status
git add .
git commit -m "describe config change"
git pull
```

You may push that local commit before or after the pull as appropriate. If you have uncommitted edits and the remote changed the same files, Git may stop and ask you to resolve the situation; it will not safely invent the intended result for you.

## Fresh Install

Use a 26.11pre NixOS minimal unstable ISO. `system.stateVersion` / `home.stateVersion` stay at `26.11`; the exact ISO build number is not a stateVersion.

```bash
curl -fL https://nixos.byetgin.com/install.sh|sudo bash
```

The live ISO already includes Git and Nix. The installer uses one temporary, writable Git checkout as the single source of truth for the whole installation.

Before touching the disk, the installer:

1. verifies the exact Samsung 990 PRO by stable `/dev/disk/by-id` + serial,
2. clones this public repository to a temporary directory on the live ISO,
3. creates an initial `flake.lock` only when the repository does not have one,
4. if a committed `flake.lock` already exists, verifies that bootstrap does not modify it,
5. evaluates the exact locked NixOS configuration,
6. builds/downloads both the locked Disko script and the complete locked NixOS system closure.

Once those checks/builds succeed, the installer automatically erases/formats the already verified Samsung system disk; there is no separate `ERASE` confirmation. It then:

1. runs the already-built `config.system.build.diskoScript`,
2. installs the already-built system closure with `nixos-install --system`, so the flake is not re-resolved after the disk is erased,
3. copies the exact Git checkout used for installation — including `.git` and its `flake.lock` — to `~/Desktop/nixos-config`,
4. changes that checkout to `byetgin:users`,
5. links `/etc/nixos` to the Desktop checkout,
6. asks interactively for the `byetgin` password through `/dev/tty`.

The exact by-id + serial check is the destructive safety boundary. The existing 1TB NVMe and 480GB SATA data disks are never Disko targets.

### After first boot

For the very first installation, the repository may not yet contain a committed `flake.lock`. After confirming the desktop works, save that exact known-good input snapshot and then take a clean `/home` baseline:

```bash
cd ~/Desktop/nixos-config
git status
git add flake.lock
git commit -m "chore: save initial flake lock (YYYY-MM-DD)"
git push

sudo snapper -c home create --description "Fresh NixOS baseline"
sudo snapper -c home list
```

The manual baseline has no timeline cleanup tag, so it is kept independently of the hourly/daily/weekly timeline cleanup policy.

On future reinstalls, the committed `flake.lock` comes down with `git clone` and is used as-is. The installer runs the lock bootstrap only as a consistency check and aborts before touching the disk if that committed lock would change. In other words, reinstalling one month later restores the **last committed known-good lock**, not whatever happens to be newest in `nixos-unstable` that day. Normal version advancement remains an explicit `nixupdate` action followed by reboot/verification and a new lock commit.

## Config layout and permissions

There is one real editable Git checkout:

```text
/home/byetgin/Desktop/nixos-config
```

It is made user-owned (`byetgin:users`), so the repository files and `.git` directory support normal editing/Git operations without sudo.

The installer creates:

```text
/etc/nixos -> /home/byetgin/Desktop/nixos-config
```

`/etc/nixos` itself is only a root-created symbolic link. Following that link reaches the same user-owned files, so editing or running Git commands from `/etc/nixos` does not create a second copy and should not require sudo.

## flake.lock in one paragraph

`flake.nix` says which rolling inputs to follow, such as `nixos-unstable`. `flake.lock` records the exact revisions currently selected. If the repository has no lock yet, the first install creates one in its temporary writable checkout and uses it for the entire install. Once that lock is committed, every later reinstall clones and uses that committed snapshot exactly; bootstrap is allowed to verify it but not silently change it. `nixapply` uses the current lock without advancing it. `nixupdate` deliberately runs `nix flake update`, which advances those revisions; after a successful reboot, commit the changed lock to make that newer snapshot the next known-good reinstall point.

## Storage

The existing data disks are never Disko format targets:

```text
/data/NVMe_1TB   -> UUID d28ebb9a-91e7-42e9-b68c-ce7725a7bfd9
/data/SATA_480G  -> UUID a2ec5392-7770-4f1c-8f1f-ba7ceb9059a3
```

Homelab SMB shares are lazy-mounted so an unavailable server cannot block boot:

```text
/data/datapool        -> //192.168.1.102/datapool
/data/fastpool-config -> //192.168.1.102/fastpool-config
```

## Rollback model

```text
NixOS generations  -> operating-system rollback
Git + flake.lock   -> exact declarative input revisions
Snapper /home      -> user-file recovery
Nix GC             -> unreachable store paths retained for 30 days
```

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

Git and GitHub CLI are both installed system-wide. Home Manager manages the user's Git settings without installing a second Git package. `pciutils` is also kept as a lightweight diagnostic toolset so commands such as `lspci` are always available when checking hardware/drivers.

## Notes

**`@snapshots` subvolume** — `/home/.snapshots` is separate so Snapper snapshots do not recursively contain themselves.

**`stateVersion`** — defined once in `flake.nix` as `nixosVersion`. It is a compatibility setting, not the package/version snapshot. Do not raise it on normal rolling updates.
