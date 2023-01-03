{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { nixpkgs, impermanence, lanzaboote, ... }@inputs: {
    nixosConfigurations.ariadne = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        lanzaboote.nixosModules.lanzaboote
	impermanence.nixosModules.impermanence
        ./configuration.nix
      ];
    };
  };
}
