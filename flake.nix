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
    opnix = {
      url = "github:brizzbuzz/opnix";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, opnix, ... }@inputs:
  let
    overlays = [
      #(import ./overlays/power-profiles-patch.nix)
    ];
  in {
    nixosConfigurations = {
      x1-carbon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/common/configuration.nix
          ./hosts/x1-carbon/configuration.nix
          ./hosts/x1-carbon/hardware-configuration.nix
          opnix.nixosModules.default
        ];
        specialArgs = {
          inherit inputs overlays;
        };
      };
      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/common/configuration.nix
          ./hosts/vm/configuration.nix
          ./hosts/vm/hardware-configuration.nix
        ];
        specialArgs = {
          inherit inputs overlays;
        };
      };
    };

    homeConfigurations = {
      "updogupdogupdog@x1-carbon" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          {
            home.username = "updogupdogupdog";
            home.homeDirectory = "/home/updogupdogupdog";
          }
          ./home/updogupdogupdog/common.nix
          ./home/updogupdogupdog/x1-carbon.nix
          opnix.homeManagerModules.default
          # ./home/updogupdogupdog/minimal.nix #For Troubleshooting
          inputs.plasma-manager.homeManagerModules.plasma-manager
        ];
        extraSpecialArgs = { inherit inputs; };
      };

      "updogupdogupdog@vm" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          {
            home.username = "updogupdogupdog";
            home.homeDirectory = "/home/updogupdogupdog";
          }
          ./home/updogupdogupdog/common.nix
          opnix.homeManagerModules.default
          #./home/updogupdogupdog/vm.nix # Currently empty -- delete when uncommented
          # ./home/updogupdogupdog/minimal.nix #For Troubleshooting
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}