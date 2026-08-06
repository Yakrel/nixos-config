{ ... }: {
  imports = [
    ./modules/home/fish.nix
    ./modules/home/git.nix
    ./modules/home/kitty.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username     = "byetgin";
    homeDirectory = "/home/byetgin";
    # Version when home-manager was first set up — do not change.
    stateVersion = "25.11";
  };
}
