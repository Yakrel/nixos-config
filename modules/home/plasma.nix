{ pkgs, lib, ... }:

{
  # Lightweight KDE customizations:
  # Uses default tools built into KDE Plasma (lookandfeeltool & kwriteconfig6)
  # instead of pulling heavy development dependencies (plasma-manager).

  home.activation.kdeCustomizations = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # 1. Dark Mode: Apply Breeze Dark theme
    $DRY_RUN_CMD ${pkgs.kdePackages.plasma-workspace}/bin/lookandfeeltool --apply org.kde.breezedark.desktop >/dev/null 2>&1 || true

    # 2. Night Color: Enable in automatic mode
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group NightColor --key Active true || true
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group NightColor --key Mode Automatic || true
    $DRY_RUN_CMD ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kwinrc --group NightColor --key NightTemperature 4500 || true
  '';
}
