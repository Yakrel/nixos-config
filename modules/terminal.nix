{ pkgs, ... }:

{
  # Registers Zsh as a system shell (/etc/shells). User-facing terminal tools
  # and their configuration are owned by Home Manager.
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    nvd
    python3
  ];
}
