# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # ============================================================================
  # BOOTLOADER & KERNEL
  # ============================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ============================================================================
  # NETWORKING & HOSTNAME
  # ============================================================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ============================================================================
  # LOCALES & TIME ZONE
  # ============================================================================
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

  # Keyboard Layouts
  services.xserver.xkb = {
    layout = "tr";
    variant = "";
  };
  console.keyMap = "trq";

  # ============================================================================
  # FONTS CONFIGURATION (SYSTEM-WIDE JETBRAINS MONO)
  # ============================================================================
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "JetBrainsMono Nerd Font" ];
        serif     = [ "JetBrainsMono Nerd Font" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji     = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  # ============================================================================
  # HARDWARE & PERFORMANCE
  # ============================================================================
  # Bluetooth Support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # SSD TRIM Support
  services.fstrim.enable = true;

  # Printing Support
  services.printing.enable = true;

  # ============================================================================
  # DISPLAY & DESKTOP ENVIRONMENT (KDE PLASMA 6)
  # ============================================================================
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # ============================================================================
  # AUDIO (PIPEWIRE)
  # ============================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ============================================================================
  # NIX SETTINGS & GARBAGE COLLECTION
  # ============================================================================
  # Enable modern CLI and search capabilities
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Auto optimize nix store
  nix.settings.auto-optimise-store = true;

  # Auto garbage collection (weekly)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ============================================================================
  # USER ACCOUNTS
  # ============================================================================
  users.users.byetgin = {
    isNormalUser = true;
    description = "Berkay Yetgin";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # ============================================================================
  # NIXPKGS & NUR CONFIGURATION
  # ============================================================================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
      inherit pkgs;
    };
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    nur.repos.jeffguorg.oh-my-pi-bin
    gh
    git
    brave-origin
    vscode
  ];

  # ============================================================================
  # SYSTEM STATE VERSION
  # ============================================================================
  system.stateVersion = "26.11";
}
