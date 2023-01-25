# user.nix
{ lib, pkgs, ... }: {

  programs.home-manager.enable = lib.mkDefault true;
  programs.bash.enable = lib.mkDefault true;
  programs.bash.bashrcExtra = lib.mkDefault ''
    eval "$(starship init bash)"
  '';
  home.packages = lib.mkBefore (with pkgs; [
    firefox-wayland
    bind
    keepassxc
    vscode
    k9s
    kubernetes-helm
    kubectl
    starship
    pfetch
  ]);

}

