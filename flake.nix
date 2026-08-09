{
  description = "Berkay Yetgin's NixOS configuration";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs/nixos-unstable";
    home-manager    = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ai-dikte = {
      url = "github:Yakrel/ai-dikte";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jdownloader-interceptor = {
      url = "github:Yakrel/jdownloader-download-interceptor";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    plasma-manager,
    disko,
    nur,
    ai-dikte,
    jdownloader-interceptor,
    ...
  }:
  let
    # Fresh install only — update this when reinstalling from a new ISO.
    # Never change on a running system (breaks stateful service compatibility).
    nixosVersion = "26.11";
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit nixosVersion;
        jdownloaderInterceptor = jdownloader-interceptor;
      };
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
            useGlobalPkgs        = true;
            useUserPackages      = true;
            sharedModules        = [ plasma-manager.homeModules.plasma-manager ];
            users.byetgin        = import ./home.nix;
            backupFileExtension  = "bak";
            extraSpecialArgs     = { inherit nixosVersion; };
          };
        }
      ];
    };
  };
}
