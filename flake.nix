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
    nix-gaming-edge = {
      url = "github:powerofthe69/nix-gaming-edge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, disko, nur, nix-gaming-edge, ... }:
  let
    # Fresh install only — update this when reinstalling from a new ISO.
    # Never change on a running system (breaks stateful service compatibility).
    nixosVersion = "26.11";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit nixosVersion; };
      modules = [
        # External package overlays — flake inputs keep them pinned with the system lock.
        {
          nixpkgs.overlays = [
            nur.overlays.default
            nix-gaming-edge.overlays.jellium-desktop
          ];
        }
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
