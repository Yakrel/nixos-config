{ config, pkgs, ... }:

{
  # Link system-wide Kitty configuration from ./kitty.conf
  environment.etc."xdg/kitty/kitty.conf".source = ./kitty.conf;

  # Shell configuration & aliases
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza --icons";
      ll = "eza -lh --icons";
      la = "eza -la --icons";
      tree = "eza --tree --icons";
      cat = "bat";
      nixupdate = "sudo nix-channel --update && sudo nixos-rebuild switch && nvd diff /run/booted-system /run/current-system";
    };
  };

  # Starship prompt
  programs.starship.enable = true;
  programs.zoxide.enable = true;

  # Terminal packages
  environment.systemPackages = with pkgs; [
    kitty
    eza
    bat
    btop
    nvd
  ];
}
