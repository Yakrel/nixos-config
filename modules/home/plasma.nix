{ ... }:

let
  # Repo-owned 4K NixOS wallpaper. Plasma scales it to the workstation's
  # 2560x1440 display without changing the 16:9 aspect ratio.
  wallpaper = "${../../assets/wallpapers/ig636-wallpaper.cam.png}";
in
{
  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      widgetStyle = "Breeze";
      colorScheme = "BreezeDark";
      iconTheme = "breeze-dark";
      wallpaper = wallpaper;
      wallpaperFillMode = "preserveAspectCrop";
    };

    # Native Plasma dynamic accent: extract the accent color from the current
    # wallpaper and keep it in sync when the wallpaper changes.
    configFile.kdeglobals.General.accentColorFromWallpaper = true;

    input.keyboard.numlockOnStartup = "on";

    kwin.nightLight = {
      enable = true;
      mode = "automatic";
      temperature.night = 4500;
    };

    # Keep the standard Plasma panel widgets, but make the task-manager pins
    # deterministic and limited to Dolphin, the preferred browser, and Kitty.
    panels = [
      {
        location = "bottom";
        floating = true;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks.launchers = [
              "preferred://filemanager"
              "preferred://browser"
              "applications:kitty.desktop"
            ];
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };

  # Make preferred://browser deterministic on a fresh install so the Plasma
  # launcher resolves to Brave Origin without requiring a GUI default-app step.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "brave-origin.desktop" ];
      "application/xhtml+xml" = [ "brave-origin.desktop" ];
      "x-scheme-handler/http" = [ "brave-origin.desktop" ];
      "x-scheme-handler/https" = [ "brave-origin.desktop" ];
    };
  };
}
