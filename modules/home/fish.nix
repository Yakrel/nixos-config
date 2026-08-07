{ pkgs, ... }: {
  # Canonical Git checkout. /etc/nixos and ~/Desktop/nixos-config point here.
  home.sessionVariables.NIXOS_CONFIG = "/home/byetgin/.config/nixos";

  programs.fish = {
    enable = true;

    # CachyOS uses the Pure Fish prompt. Keep the same clean two-line prompt
    # (working directory + Git branch, then ❯) instead of maintaining Starship.
    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];

    shellAliases = {
      ls = "eza --icons";
      ll = "eza -lh --icons";
      la = "eza -la --icons";
      tree = "eza --tree --icons";
      cat = "bat";

      # Update rolling flake inputs, build the next boot generation, then show diff.
      # Kernel/Mesa/Plasma changes activate after reboot instead of mid-session.
      nixupdate = "nix flake update --flake $NIXOS_CONFIG && sudo nixos-rebuild boot --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /nix/var/nix/profiles/system";

      # Rebuild the current locked config immediately without advancing inputs.
      nixswitch = "sudo nixos-rebuild switch --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /run/current-system";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
