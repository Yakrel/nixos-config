{ pkgs, lib, ... }:

let
  # Photo by Tyler Lastovich on Unsplash (ddLiNMqWAOM).
  wallpaper = pkgs.fetchurl {
    url = "https://images.unsplash.com/photo-1554176259-aa961fc32671?ixlib=rb-4.0.3&q=85&fm=jpg&crop=entropy&cs=srgb&dl=tyler-lastovich-ddLiNMqWAOM-unsplash.jpg";
    hash = "sha256-+pjhBCVwjuzx/r11nqZJI79FPhuPGqrzD1Hd90nEQys=";
    name = "tyler-lastovich-ddLiNMqWAOM-unsplash.jpg";
  };

  wallpaperActivator = pkgs.writeShellApplication {
    name = "apply-plasma-wallpaper";
    runtimeInputs = [ pkgs.kdePackages.plasma-workspace ];
    runtimeEnv.QT_QPA_PLATFORM = "minimal";
    text = ''
      plasma-apply-wallpaperimage --fill-mode preserveAspectCrop "${wallpaper}"
    '';
  };
in
{
  # Lightweight Plasma defaults without plasma-manager. kwriteconfig6 edits only
  # the relevant KDE keys and does not require a running graphical session.
  home.activation.kdeCustomizations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Breeze Dark from the first login.
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key ColorScheme BreezeDark
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group Icons --key Theme breeze-dark

    # Force NumLock on when the Plasma session starts (KDE: 0=on, 1=off, 2=unchanged).
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kcminputrc --group Keyboard --key NumLock 0

    # Night Light: automatic sunset-to-sunrise schedule from GeoClue.
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group NightColor --key Active true
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group NightColor --key Mode Automatic
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group NightColor --key NightTemperature 4500

    # Apply immediately when a Plasma session is available. The autostart entry
    # below is the reliable fallback for rebuilds performed outside the session.
    $DRY_RUN_CMD ${wallpaperActivator}/bin/apply-plasma-wallpaper || true
  '';

  # Re-apply the declarative wallpaper when Plasma starts. KDE cannot reliably
  # switch an existing wallpaper through static config files alone.
  xdg.autostart = {
    enable = true;
    entries = [
      (pkgs.makeDesktopItem {
        name = "apply-plasma-wallpaper";
        desktopName = "Apply Plasma wallpaper";
        exec = "${wallpaperActivator}/bin/apply-plasma-wallpaper";
        extraConfig.X-KDE-AutostartScript = "true";
      } + /share/applications/apply-plasma-wallpaper.desktop)
    ];
  };
}
