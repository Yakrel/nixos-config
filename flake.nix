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
    ai-dikte = {
      url = "github:Yakrel/ai-dikte";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, disko, nur, ai-dikte, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # Fresh install only — update this when reinstalling from a new ISO.
    # Never change on a running system (breaks stateful service compatibility).
    nixosVersion = "26.11";
  in {
    # Live-installer/bootstrap tools only. These are not installed into the
    # resulting NixOS system unless explicitly added to systemPackages later.
    packages.${system}.bootstrap-tools = pkgs.buildEnv {
      name = "nixos-bootstrap-tools";
      paths = [ pkgs.age pkgs.whois ];
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit nixosVersion; };
      modules = [
        # NUR overlay — as a flake input instead of builtins.fetchTarball
        { nixpkgs.overlays = [ nur.overlays.default ]; }
        disko.nixosModules.disko
        ./disko.nix
        ai-dikte.nixosModules.default
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
