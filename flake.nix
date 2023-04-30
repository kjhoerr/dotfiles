{
  inputs = {
    nixos-pkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Temporary until lanzaboote refactors its dependencies
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixos-pkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # Secure Boot for NixOS
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixos-pkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
    };

    # User profile manager based on Nix
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Links persistent folders into system
    impermanence.url = "github:nix-community/impermanence";

    # Provides module support for specific vendor hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Base user config modules to be overwritten
      homeModules = [
        ./.config/nixos/home/user.nix
        ./.config/nixos/home/git.nix
        ./.config/nixos/home/gnome.nix
        ./.config/nixos/home/neovim.nix
        ./.config/nixos/home/helix.nix
        ./.config/nixos/home/gpg-agent.nix
      ];

      # Base OS configs, adapts to system configs
      osModules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.impermanence.nixosModules.impermanence
        ./.config/nixos/os/persist.nix
        ./.config/nixos/os/secure-boot.nix
        ./.config/nixos/os/system.nix
      ];

      # Function to build a home configuration from user modules
      homeUser = (userModules: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # userModules overwrites, so is appended
        modules = homeModules ++ userModules;
      });

      # Function to build a nixos configuration from system modules
      nixosSystem = (systemModules: nixpkgs.lib.nixosSystem {
        inherit system;
        # osModules depends on some values from systemModules, so is appended
        modules = systemModules ++ osModules;
      });

    in {
      homeConfigurations = {

        khoerr = homeUser [ ./.config/nixos/users/khoerr.nix ];

        kjhoerr = homeUser [ ./.config/nixos/users/kjhoerr.nix ];

      };
      nixosConfigurations = {

        ariadne = nixosSystem [
          inputs.nixos-hardware.nixosModules.framework
          ./.config/nixos/systems/ariadne.nix
        ];

        cronos = nixosSystem [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
          ./.config/nixos/systems/cronos.nix
        ];

        whisker = nixosSystem [
          ./.config/nixos/systems/whisker.nix
        ];

      };
    };
}
