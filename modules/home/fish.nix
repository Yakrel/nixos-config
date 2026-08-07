{ pkgs, ... }: {
  # The real Git checkout lives on the Desktop; /etc/nixos is a symlink to it.
  home.sessionVariables.NIXOS_CONFIG = "/home/byetgin/Desktop/nixos-config";

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

      # Apply the config exactly as currently locked. Does not advance flake.lock.
      nixapply = "sudo nixos-rebuild switch --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /run/current-system";

      # Explicit rolling upgrade: advance flake.lock and prepare the new system for next boot.
      # Kernel/Mesa/Plasma changes activate after reboot instead of mid-session.
      nixupdate = "nix flake update --flake $NIXOS_CONFIG && sudo nixos-rebuild boot --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /nix/var/nix/profiles/system";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
