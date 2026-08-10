{ pkgs, ... }:

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

    # KScreen's EDID-preferred mode can use a lower refresh rate than the
    # display actually supports. At each Plasma login, keep the preferred
    # resolution but select the highest refresh rate exposed for that size.
    # This stays connector/model agnostic and works for every enabled output.
    startup.startupScript.max-refresh-rate = {
      runAlways = true;
      text = ''
        kscreen="${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor"
        jq="${pkgs.jq}/bin/jq"

        # Give KScreen a moment to restore the session's output configuration.
        sleep 2

        config=""
        attempt=0
        while [ "$attempt" -lt 5 ]; do
          if config="$("$kscreen" -j 2>/dev/null)" && [ -n "$config" ]; then
            break
          fi
          attempt=$((attempt + 1))
          sleep 1
        done

        [ -n "$config" ] || exit 0

        printf '%s\n' "$config" | "$jq" -r '
          .outputs[]
          | select(.connected == true and .enabled == true)
          | . as $output
          | ($output.preferredModes[0] // $output.currentModeId) as $baseId
          | ([ $output.modes[] | select(.id == $baseId) ][0]
             // [ $output.modes[] | select(.id == $output.currentModeId) ][0]) as $base
          | select($base != null)
          | [ $output.modes[]
              | select(.size.width == $base.size.width and .size.height == $base.size.height)
            ]
          | max_by(.refreshRate) as $best
          | select($best != null)
          | [ $output.name, $output.currentModeId, $best.id ]
          | @tsv
        ' | while IFS="$(printf '\t')" read -r output current best; do
          if [ -n "$best" ] && [ "$current" != "$best" ]; then
            "$kscreen" "output.$output.mode.$best"
          fi
        done
      '';
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
