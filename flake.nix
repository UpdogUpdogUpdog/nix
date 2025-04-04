{
  description = "Updog's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      x1-carbon = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/x1-carbon/configuration.nix
          ./hosts/x1-carbon/hardware-configuration.nix
          ./modules/common.nix
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };

    homeConfigurations = {
      updogupdogupdog = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          {
            home.username = "updogupdogupdog";
            home.homeDirectory = "/home/updogupdogupdog";
          }
          ./home/updogupdogupdog/x1-carbon.nix
          #./home/updogupdogupdog/minimal.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };

  
}
