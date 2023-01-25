# home/khoerr.nix
# Requires home-manager flake
{ config, lib, pkgs, ... }:
let
  common = import ./common.nix { lib=lib; pkgs=pkgs; };
in {

  home.username = "khoerr";
  home.homeDirectory = "/home/khoerr";

  nixpkgs.config = common.nixpkgs.config;

  home.packages = common.packages ++ (with pkgs; [
    teams
    microsoft-edge
  ]);

  programs = lib.mkMerge [
    common.programs
    {
      git.userEmail = "khoerr@ksmpartners.com";
    }
  ];
  services = common.services;

  home.stateVersion = "22.11";

}

