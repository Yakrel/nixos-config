{ pkgs, lib, ... }:

{
  # Lightweight Plasma defaults without plasma-manager. kwriteconfig6 edits only
  # the relevant KDE keys and does not require a running graphical session.
  home.activation.kdeCustomizations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Breeze Dark from the first login.
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key ColorScheme BreezeDark
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group Icons --key Theme breeze-dark

    # Night Light: automatic sunset-to-sunrise schedule from GeoClue.
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group NightColor --key Active true
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group NightColor --key Mode Automatic
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group NightColor --key NightTemperature 4500
  '';
}
