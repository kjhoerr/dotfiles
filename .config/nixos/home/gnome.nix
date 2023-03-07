{ pkgs, ... }: {

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "clipboard-history@alexsaveau.dev"
        "gsconnect@andyholmes.github.io"
        "tailscale-status@maxgallup.github.com"
        "nightthemeswitcher@romainvigier.fr"
        "GPaste@gnome-shell-extensions.gnome.org"
      ];
      favorite-apps = [
        "firefox.desktop"
        "org.keepassxc.KeePassXC.desktop"
        "code.desktop"
        "org.gnome.Nautilus.desktop"
        "com.raggesilver.BlackBox.desktop"
      ];
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      # All the below are installed at the system level
      # Could instead use `gtk.cursorTheme`, etc. and reference the actual packages
      cursor-theme = "capitaine-cursors";
      document-font-name = "Merriweather 11";
      font-name = "IBM Plex Sans Arabic 11";
      monospace-font-name = "FuraMono Nerd Font 10";
    };
  };

}
