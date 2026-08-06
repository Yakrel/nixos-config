{ nixosVersion, ... }: {
  imports = [
    ./modules/home/fish.nix
    ./modules/home/git.nix
    ./modules/home/kitty.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username     = "byetgin";
    homeDirectory = "/home/byetgin";
    # From flake.nix — change only on fresh installs.
    stateVersion = nixosVersion;
  };
}
