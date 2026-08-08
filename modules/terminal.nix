{ pkgs, ... }:

{
  # Registers Zsh as a system shell (/etc/shells).
  # User config (Oh My Zsh, aliases, zoxide) lives in Home Manager.
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    eza
    bat
    btop
    nvd
    python3
  ];
}
