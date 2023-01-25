# home/kjhoerr.nix
# Requires home-manager flake
{ config, lib, pkgs, ... }:
let
  common = import ./common.nix { lib=lib; pkgs=pkgs; };
in {

  home.username = "kjhoerr";
  home.homeDirectory = "/home/kjhoerr";

  nixpkgs.config = common.nixpkgs.config;

  home.packages = common.packages ++ (with pkgs; [
    runelite
    discord-canary
  ]);

  programs = common.programs;
  services = lib.mkMerge [
    common.services
    {
      syncthing.enable = true;
    }
  ];

  home.stateVersion = "22.11";

}

