{ config, pkgs, nixosVersion, ... }:

{
  imports = [
    ./modules/hardware.nix
    ./modules/storage.nix
    ./modules/terminal.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Track the newest stable kernel packaged by nixos-unstable (never an RC).
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Locale and keyboard
  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  services.xserver.xkb.layout = "tr";
  console.keyMap = "trq";

  fonts = {
    packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
  };

  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";
    persistentTimer = true;

    configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ "byetgin" ];
      SYNC_ACL = true;
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 3;
      TIMELINE_LIMIT_DAILY = 2;
      TIMELINE_LIMIT_WEEKLY = 1;
      TIMELINE_LIMIT_MONTHLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  services.printing.enable = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Thunderbird replaces KDE PIM; avoid pulling Akonadi/KDEPIM runtime.
  programs.kde-pim.enable = false;

  # Keep one application per job where practical.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole   # Kitty
    kate      # VS Code
    elisa     # Jellyfin Desktop / browser
    okular    # Brave has a built-in PDF viewer
    discover  # Packages are managed declaratively with Nix
    khelpcenter
  ];

  # xterm is part of the default X server package set, not the Plasma package set.
  services.xserver.excludePackages = [ pkgs.xterm ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Keep rollback generations longer. Disk space is cheap on a 2TB NVMe.
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 30d";
  };

  zramSwap.enable = true;

  users.users.byetgin = {
    isNormalUser = true;
    uid = 1000;
    description = "Berkay Yetgin";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    gh
    pciutils
    nur.repos.jeffguorg.oh-my-pi-bin
    brave-origin
    vscode
    jellyfin-desktop
    obsidian
    thunderbird
  ];

  system.stateVersion = nixosVersion;
}
