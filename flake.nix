{
  inputs = {
    nixos-pkgs.url = "github:NixOS/nixpkgs/nixos-23.05-small";
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

    # Module for running NixOS as WSL2 instance
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixos-pkgs";
    };

    # Service to fix libraries and links for NixOS hosting as VSCode remote
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
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
      lib = inputs.nixos-pkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Base user config modules
      homeModules = [
        ./.config/nixos/home/tui.nix
        ./.config/nixos/home/git.nix
        ./.config/nixos/home/neovim.nix
        ./.config/nixos/home/helix.nix
        ./.config/nixos/home/gpg-agent.nix
      ];

      # Additional user applications and configurations
      guiModules = [
        ./.config/nixos/home/applications.nix
        ./.config/nixos/home/gnome.nix
      ];

      # Base OS configs, adapts to system configs
      osModules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.impermanence.nixosModules.impermanence
        inputs.nixos-hardware.nixosModules.common-hidpi
        ./.config/nixos/os/persist.nix
        ./.config/nixos/os/secure-boot.nix
        ./.config/nixos/os/system.nix
      ];

      # User config modules for hosting services
      serverHomeModules = [
        inputs.vscode-server.nixosModules.home
        ./.config/nixos/home/services.nix
      ];

      # OS config modules for base WSL system
      wslModules = [
        "${inputs.nixos-pkgs}/nixos/modules/profiles/minimal.nix"
        inputs.nixos-wsl.nixosModules.wsl
        ./.config/nixos/systems/wsl.nix
      ];

      # Function to build a home configuration from user modules
      homeUser = (userModules: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # userModules overwrites, so is appended
        modules = homeModules ++ guiModules ++ userModules;
      });

      # Function to build a nixos configuration from system modules
      nixosSystem = (systemModules: lib.nixosSystem {
        inherit system;
        # osModules depends on some values from systemModules, so is appended
        modules = systemModules ++ osModules;
      });

      # Function to build a nixos configuration for WSL
      wslSystem = (systemModules: lib.nixosSystem {
        inherit system;
        modules = systemModules ++ wslModules;
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
          inputs.nixos-hardware.nixosModules.common-gpu-amd
          ./.config/nixos/systems/whisker.nix
        ];

        nixos-wsl = wslSystem [
          # By design, user integration is tightly coupled to system for WSL
          # Include home-manager module here so all updates are shipped together
          home-manager.nixosModules.home-manager
          {
            users.users.kjhoerr.extraGroups = lib.mkAfter [ "docker" ];
            wsl.defaultUser = "kjhoerr";
            home-manager.users.kjhoerr = {
              imports = homeModules ++ serverHomeModules ++ [
                ./.config/nixos/users/kjhoerr.nix
              ];
            };
          }
        ];

      };
    };
}
