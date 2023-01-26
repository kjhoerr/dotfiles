# home/kjhoerr.nix
# Requires home-manager flake
{ pkgs, ... }: {

  home.username = "kjhoerr";
  home.homeDirectory = "/home/kjhoerr";

  home.packages = with pkgs; [
    doctl
    mkcert
    runelite
    discord-canary
  ];

  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;
  services.pueue.enable = true;

  home.stateVersion = "22.11";
}

