{ pkgs, ... }:

{
  # Registers Fish as a system shell (/etc/shells).
  # User config (Pure prompt, aliases, zoxide) lives in Home Manager.
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    eza
    bat
    btop
    nvd
    python3
  ];
}
