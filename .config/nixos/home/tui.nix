# tui.nix
{ lib, pkgs, ... }: {

  # Use lib.mkDefault where possible so user config can override without lib.mkForce

  # Install packages via programs.* where possible
  # May include extra config OOTB that the package does not
  programs.zsh = {
    enable = lib.mkDefault true;
    history.extended = true;
  };
  programs.home-manager.enable = lib.mkDefault true;
  programs.k9s.enable = lib.mkDefault true;
  programs.kakoune.enable = lib.mkDefault true;
  programs.ripgrep.enable = lib.mkDefault true;
  programs.starship.enable = lib.mkDefault true;
  programs.java.enable = lib.mkDefault true;
  programs.java.package = lib.mkDefault pkgs.jdk17_headless;

  home.packages = lib.mkBefore (with pkgs; [
    bind
    file
    jq
    kubernetes-helm
    kubectl
    pfetch
  ]);

}

