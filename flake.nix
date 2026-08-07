{
  description = "Berkay Yetgin's NixOS configuration";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs/nixos-unstable";
    home-manager    = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { nixpkgs, home-manager, disko, nur, ... }:
  let
    # Fresh install only — update this when reinstalling from a new ISO.
    # Never change on a running system (breaks stateful service compatibility).
    nixosVersion = "26.11";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit nixosVersion; };
      modules = [
        # NUR overlay — as a flake input instead of builtins.fetchTarball
        { nixpkgs.overlays = [ nur.overlays.default ]; }
        disko.nixosModules.disko
        ./disko.nix
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs      = true;
            useUserPackages    = true;
            users.byetgin      = import ./home.nix;
            backupFileExtension = "bak";
            extraSpecialArgs   = { inherit nixosVersion; };
          };
        }
      ];
    };
  };
}
