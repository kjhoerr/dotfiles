{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { nixpkgs, impermanence, lanzaboote, home-manager, nixos-hardware, ... }: {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

    homeConfigurations = {
      "kjhoerr" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./.config/nixos/home/kjhoerr.nix ];
      };
      "khoerr" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./.config/nixos/home/khoerr.nix ];
      };
    };
    nixosConfigurations = {
      ariadne = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.framework
          lanzaboote.nixosModules.lanzaboote
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          ./.config/nixos/ariadne.nix
          ./.config/nixos/common
        ];
      };
      cronos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
          lanzaboote.nixosModules.lanzaboote
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          ./.config/nixos/cronos.nix
          ./.config/nixos/common
        ];
      };
      whisker = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          lanzaboote.nixosModules.lanzaboote
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          ./.config/nixos/hardware-whisker.nix
          ./.config/nixos/whisker.nix
        ];
      };
    };
  };
}
