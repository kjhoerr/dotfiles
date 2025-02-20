# home/khoerr.nix
# Requires home-manager flake
{ pkgs, ... }: {

  home.username = "khoerr";
  home.homeDirectory = "/home/khoerr";

  home.packages = with pkgs; [
    azure-cli
    citrix_workspace
    kubelogin
    liquibase
    nodejs
    openssh
    onedrive
  ];
  playwright.enable = true;
  helix.lsps = [
    "bash"
    "css"
    "dockerfile"
    "html"
    "java"
    "json"
    "markdown"
    "nix"
    "python"
    "toml"
    "typescript"
    "yaml"
  ];

  programs.git.userEmail = "khoerr@ksmpartners.com";
  programs.gpg.mutableKeys = true;
  programs.gpg.mutableTrust = true;

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "gsconnect@andyholmes.github.io"
        "nightthemeswitcher@romainvigier.fr"
        "GPaste@gnome-shell-extensions.gnome.org"
        "onedrive@client.onedrive.com"
        "blur-my-shell@aunetx"
        "luminus-shell-y@dikasp.gitlab"
      ];
      favorite-apps = [
        "chromium-browser.desktop"
        "org.keepassxc.KeePassXC.desktop"
        "code.desktop"
        "org.gnome.Nautilus.desktop"
        "com.raggesilver.BlackBox.desktop"
      ];
    };
  };

  home.stateVersion = "22.11";
}

