{
  description = "Updog's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }@inputs:
  let
    overlays = [
      (import ./overlays/power-profiles-patch.nix)
    ];
  in {
    nixosConfigurations = {
      x1-carbon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/x1-carbon/configuration.nix
          ./hosts/x1-carbon/hardware-configuration.nix
          ./modules/common.nix
        ];
        specialArgs = {
          inherit inputs overlays;
        };
      };
    };

    homeConfigurations = {
      updogupdogupdog = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          {
            home.username = "updogupdogupdog";
            home.homeDirectory = "/home/updogupdogupdog";
          }
          ./home/updogupdogupdog/x1-carbon.nix
          # ./home/updogupdogupdog/minimal.nix
          inputs.plasma-manager.homeManagerModules.plasma-manager
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}