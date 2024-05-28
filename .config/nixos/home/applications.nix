# applications.nix
{ lib, pkgs, ... }: {

  # Use lib.mkDefault where possible so user config can override without lib.mkForce

  # Install packages via programs.* where possible
  # May include extra config OOTB that the package does not
  programs.firefox.enable = lib.mkDefault true;
  programs.vscode.enable = lib.mkDefault true;

  home.packages = lib.mkBefore (with pkgs; [
    blackbox-terminal
    foliate
    gnumeric
    keepassxc
    obsidian
    openlens
    switcheroo
    ungoogled-chromium
  ]);

}

