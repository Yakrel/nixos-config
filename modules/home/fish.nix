{ ... }: {
  # NIXOS_CONFIG: lets nixupdate/nixswitch locate the config directory.
  # Update this if you clone the repo to a different path.
  home.sessionVariables.NIXOS_CONFIG = "/home/byetgin/nixos-config";

  programs.fish = {
    enable = true;
    shellAliases = {
      ls   = "eza --icons";
      ll   = "eza -lh --icons";
      la   = "eza -la --icons";
      tree = "eza --tree --icons";
      cat  = "bat";
      # Update flake + rebuild + show what changed
      nixupdate = "nix flake update $NIXOS_CONFIG && sudo nixos-rebuild switch --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /run/current-system";
      # Rebuild only (without updating the flake)
      nixswitch = "sudo nixos-rebuild switch --flake $NIXOS_CONFIG#nixos && nvd diff /run/booted-system /run/current-system";
    };
  };

  programs.starship.enable = true;

  programs.zoxide = {
    enable              = true;
    enableFishIntegration = true;
  };
}
