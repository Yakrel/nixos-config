{ ... }:

{
  # The real Git checkout lives on the Desktop; /etc/nixos is a symlink to it.
  home.sessionVariables.NIXOS_CONFIG = "/home/byetgin/Desktop/nixos-config";

  programs = {
    fastfetch = {
      enable = true;
      settings = {
        # Based on Fastfetch's official examples/2 preset: use the full
        # detected NixOS logo and group a useful workstation-sized inventory.
        logo.padding.right = 3;

        display = {
          separator = "  ";
          color.keys = "blue";
          key = {
            type = "icon";
            paddingLeft = 1;
          };
        };

        modules = [
          {
            type = "title";
            color = {
              user = "cyan";
              at = "white";
              host = "blue";
            };
          }
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "de"
          "wm"
          "terminal"
          "terminalfont"
          "separator"
          "cpu"
          "gpu"
          "memory"
          "disk"
          "display"
          {
            type = "localip";
            compact = true;
          }
          {
            type = "colors";
            key = "Colors";
            symbol = "circle";
            block.range = [
              1
              6
            ];
          }
        ];
      };
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # Keep the existing behavior: show one static fetch in each new
      # interactive Kitty shell, without the previous startup animation.
      initContent = ''
        if [[ -o interactive && -t 1 && "$TERM" == "xterm-kitty" ]]; then
          fastfetch
        fi
      '';

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };

      shellAliases = {
        # eza's Home Manager module owns installation/integration and icon
        # behavior. Preserve the workstation's existing alias semantics.
        ll = "eza -lh";
        la = "eza -la";
        tree = "eza --tree";
        cat = "bat --paging=never";
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
    };

    bat.enable = true;
    btop.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
