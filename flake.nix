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

  outputs = { nixpkgs, impermanence, lanzaboote, home-manager, nixos-hardware, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      homeModules = [ ./.config/nixos/home/common.nix ];
      osModules = [
        lanzaboote.nixosModules.lanzaboote
        impermanence.nixosModules.impermanence
        ./.config/nixos/common
      ];
    in {
      homeConfigurations = {
        "kjhoerr" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = homeModules ++ [ ./.config/nixos/home/kjhoerr.nix ];
        };
        "khoerr" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = homeModules ++ [ ./.config/nixos/home/khoerr.nix ];
        };
      };
      nixosConfigurations = {
        ariadne = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nixos-hardware.nixosModules.framework
            ./.config/nixos/ariadne.nix
          ] ++ osModules;
        };
        cronos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
            ./.config/nixos/cronos.nix
          ] ++ osModules;
        };
        whisker = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./.config/nixos/whisker.nix
          ] ++ osModules;
        };
      };
    };
}
