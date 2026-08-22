{ nixosVersion, ... }: {
  imports = [
    ./modules/home/zsh.nix
    ./modules/home/git.nix
    ./modules/home/kitty.nix
    ./modules/home/plasma.nix
    ./modules/home/places.nix
    ./modules/home/omp.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username     = "byetgin";
    homeDirectory = "/home/byetgin";
    # From flake.nix — change only on fresh installs.
    stateVersion = nixosVersion;
  };
}
