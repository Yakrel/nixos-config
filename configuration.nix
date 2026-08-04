# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
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

  services.xserver.xkb = {
    layout = "tr";
    variant = "";
  };
  console.keyMap = "trq";

  # Use Omarchy's JetBrains Mono Nerd Font only for monospace applications.
  fonts = {
    packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
  };

  # Hardware and peripherals
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.fstrim.enable = true;

  # Keep a small timeline of /home snapshots for recovering user files.
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
      TIMELINE_LIMIT_HOURLY = 6;
      TIMELINE_LIMIT_DAILY = 3;
      TIMELINE_LIMIT_WEEKLY = 2;
      TIMELINE_LIMIT_MONTHLY = 1;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  services.printing.enable = true;

  # KDE Plasma
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    elisa
    khelpcenter
    kate
  ];
  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Keep two weeks of rollback history, then collect unreachable store paths.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Git & Shell
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Berkay Yetgin";
        email = "85676216+Yakrel@users.noreply.github.com";
      };
    };
  };
  programs.fish.enable = true;

  # User
  users.users.byetgin = {
    isNormalUser = true;
    description = "Berkay Yetgin";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];
  };

  # Packages
  nixpkgs.config.allowUnfree = true;

  # Intentionally track NUR main to keep this unstable system bleeding edge.
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
      inherit pkgs;
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    nur.repos.jeffguorg.oh-my-pi-bin
    gh
    git
    brave-origin
    vscode
    jellyfin-desktop
    obsidian
    thunderbird
    kitty
  ];

  # Compatibility baseline from the initial installation; do not update it
  # when updating NixOS.
  system.stateVersion = "26.11";
}
