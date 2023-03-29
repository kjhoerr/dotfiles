# home/khoerr.nix
# Requires home-manager flake
{ pkgs, ... }: {

  home.username = "khoerr";
  home.homeDirectory = "/home/khoerr";

  programs.git.userEmail = "khoerr@ksmpartners.com";

  home.stateVersion = "22.11";
}

