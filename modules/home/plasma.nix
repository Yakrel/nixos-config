{ pkgs, ... }:

let
  # Photo by Bailey Zindel on Unsplash (Dark Minimalist Cyber Mountain).
  wallpaper = pkgs.fetchurl {
    url = "https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=2560&auto=format&fit=crop";
    hash = "sha256-3QmiRYbsPnlPmlbf8x1kX3CNsHMxBvmXJhXZceJ6aRk=";
    name = "bailey-zindel-unsplash-mountain.jpg";
  };
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
