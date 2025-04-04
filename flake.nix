{
  description = "Updog's NixOS + Home Manager config (24.11 stable-ish)";

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
          /etc/nixos/hardware-configuration.nix
          home-manager.nixosModules.home-manager
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
          ./home/updogupdogupdog/x1-carbon.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
  };
}
