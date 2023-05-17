# user.nix
{ lib, pkgs, ... }: {

  # Use lib.mkDefault where possible so user config can override without lib.mkForce

  # Install packages via programs.* where possible
  # May include extra config OOTB that the package does not
  programs.bash.enable = lib.mkDefault true;
  programs.firefox.enable = lib.mkDefault true;
  programs.home-manager.enable = lib.mkDefault true;
  programs.k9s.enable = lib.mkDefault true;
  programs.kakoune.enable = lib.mkDefault true;
  programs.starship.enable = lib.mkDefault true;
  programs.vscode.enable = lib.mkDefault true;

  home.packages = lib.mkBefore (with pkgs; [
    bind
    blackbox-terminal
    keepassxc
    kubernetes-helm
    kubectl
    pfetch
    microsoft-edge-dev
  ]);

  xdg.desktopEntries.microsoft-edge-dev = {
    name = "Microsoft Edge (dev)";
    genericName = "Web Browser";
    exec = "microsoft-edge-dev -enable-features=UseOzonePlatform -ozone-platform=wayland %U";
    terminal = false;
    icon = "microsoft-edge-dev";
    type = "Application";
    categories = [ "Network" "WebBrowser" ];
    mimeType = [ "application/pdf" "application/rdf+xml" "application/rss+xml" "application/xhtml+xml" "application/xhtml_xml" "application/xml" "image/gif" "image/jpeg" "image/png" "image/webp" "text/html" "text/xml" "x-scheme-handler/http" "x-scheme-handler/https"];
  };

}

