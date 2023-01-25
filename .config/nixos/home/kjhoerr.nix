# home/kjhoerr.nix
# Requires home-manager flake
{ pkgs, ... }: {

  home.username = "kjhoerr";
  home.homeDirectory = "/home/kjhoerr";

  home.packages = with pkgs; [
    runelite
    discord-canary
  ];

  services.syncthing.enable = true;

  home.stateVersion = "22.11";
}

