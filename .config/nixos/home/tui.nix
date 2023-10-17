# tui.nix
{ lib, pkgs, ... }: {

  # Use lib.mkDefault where possible so user config can override without lib.mkForce

  # Install packages via programs.* where possible
  # May include extra config OOTB that the package does not
  programs.bash.enable = lib.mkDefault true;
  programs.home-manager.enable = lib.mkDefault true;
  programs.k9s.enable = lib.mkDefault true;
  programs.kakoune.enable = lib.mkDefault true;
  programs.starship.enable = lib.mkDefault true;
  programs.java.enable = lib.mkDefault true;
  programs.java.package = lib.mkDefault pkgs.jdk17_headless;

  home.packages = lib.mkBefore (with pkgs; [
    bind
    jq
    kubernetes-helm
    kubectl
    pfetch
  ]);

}

