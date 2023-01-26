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

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      homeModules = [ ./.config/nixos/home ];
      osModules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.impermanence.nixosModules.impermanence
        ./.config/nixos/os
      ];
    in {
      homeConfigurations = {
        kjhoerr = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = homeModules ++ [ ./.config/nixos/users/kjhoerr.nix ];
        };
        khoerr = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = homeModules ++ [ ./.config/nixos/users/khoerr.nix ];
        };
      };
      nixosConfigurations = {
        ariadne = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.nixos-hardware.nixosModules.framework
            ./.config/nixos/systems/ariadne.nix
          ] ++ osModules;
        };
        cronos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
            ./.config/nixos/systems/cronos.nix
          ] ++ osModules;
        };
        whisker = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./.config/nixos/systems/whisker.nix
          ] ++ osModules;
        };
      };
    };
}
