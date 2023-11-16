{
  inputs = {
    nixos-pkgs.url = "github:NixOS/nixpkgs/staging-next";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Secure Boot for NixOS
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixos-pkgs";
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

    # fw ectool as configured for FW13 7040 AMD (until patch is upstreamed)
    fw-ectool = {
      url = "github:tlvince/ectool.nix";
      inputs.nixpkgs.follows = "nixos-pkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = inputs.nixos-pkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      osOverlays = [
        (_: _: { fw-ectool = inputs.fw-ectool.packages.${system}.ectool; })
        (self: super: {
          # Override gnomeExtensions with unstable variant
          # See: https://github.com/NixOS/nixpkgs/issues/228504
          inherit (pkgs) gnomeExtensions;
        })
      ];

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

      # User config modules for hosting services
      serverHomeModules = [
        inputs.vscode-server.nixosModules.home
        ./.config/nixos/home/services.nix
      ];

      # Base OS configs, adapts to system configs
      osModules = [
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.impermanence.nixosModules.impermanence
        inputs.nixos-hardware.nixosModules.common-hidpi
        ./.config/nixos/os/persist.nix
        ./.config/nixos/os/secure-boot.nix
        ./.config/nixos/os/system.nix
        ./.config/nixos/os/upgrade.nix
        {
          nixpkgs.overlays = osOverlays;
        }
      ];

      # OS config modules for base WSL system
      wslModules = [
        "${inputs.nixos-pkgs}/nixos/modules/profiles/minimal.nix"
        inputs.nixos-wsl.nixosModules.wsl
        ./.config/nixos/os/upgrade.nix
      ];

      # Function to build a home configuration from user modules
      homeUser = (userModules: inputs.home-manager.lib.homeManagerConfiguration {
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
          inputs.nixos-hardware.nixosModules.framework-13-7040-amd
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
          inputs.home-manager.nixosModules.home-manager
          ./.config/nixos/systems/wsl.nix
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
