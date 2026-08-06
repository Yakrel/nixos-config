{ pkgs, ... }:

{
  # Registers fish as a system shell (/etc/shells).
  # User config (aliases, starship, zoxide) lives in home-manager.
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    eza
    bat
    btop
    nvd
  ];
}
