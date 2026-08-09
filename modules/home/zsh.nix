{ ... }:

{
  # The real Git checkout lives on the Desktop; /etc/nixos is a symlink to it.
  home.sessionVariables.NIXOS_CONFIG = "/home/byetgin/Desktop/nixos-config";

  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

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
        cat = "bat";

        # Apply the config exactly as currently locked. Does not advance flake.lock.
        nixapply = "sudo nixos-rebuild switch --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /run/current-system";

        # Explicit rolling upgrade: advance flake.lock and prepare the new system for next boot.
        # Kernel/Mesa/Plasma changes activate after reboot instead of mid-session.
        nixupdate = "nix flake update --flake $NIXOS_CONFIG && sudo nixos-rebuild boot --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /nix/var/nix/profiles/system";
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
