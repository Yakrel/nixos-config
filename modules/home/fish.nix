{ ... }: {
  # NIXOS_CONFIG: lets nixupdate/nixswitch locate the config directory.
  # Update this if you clone the repo to a different path.
  home.sessionVariables.NIXOS_CONFIG = "/home/byetgin/Desktop/nixos-config";

  programs.fish = {
    enable = true;
    shellAliases = {
      ls   = "eza --icons";
      ll   = "eza -lh --icons";
      la   = "eza -la --icons";
      tree = "eza --tree --icons";
      cat  = "bat";
      # Update flake inputs + create a bootable generation + show changes.
      # New kernel/graphics stack is activated after reboot, not inside current session.
      nixupdate = "nix flake update $NIXOS_CONFIG && sudo nixos-rebuild boot --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /nix/var/nix/profiles/system";
      # Rebuild only (without updating flake inputs).
      nixswitch = "sudo nixos-rebuild switch --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /run/current-system";
    };
  };

  programs.starship.enable = true;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
