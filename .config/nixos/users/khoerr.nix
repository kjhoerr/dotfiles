# home/khoerr.nix
# Requires home-manager flake
{ pkgs, ... }: {

  home.username = "khoerr";
  home.homeDirectory = "/home/khoerr";

  home.packages = with pkgs; [ onedrive ];

  programs.git.userEmail = "khoerr@ksmpartners.com";

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "gsconnect@andyholmes.github.io"
        "nightthemeswitcher@romainvigier.fr"
        "GPaste@gnome-shell-extensions.gnome.org"
      ];
      favorite-apps = [
        "microsoft-edge-dev.desktop"
        "org.keepassxc.KeePassXC.desktop"
        "code.desktop"
        "org.gnome.Nautilus.desktop"
        "com.raggesilver.BlackBox.desktop"
      ];
    };
  };

  home.stateVersion = "22.11";
}

