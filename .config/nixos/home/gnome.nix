{ pkgs, ... }: {

  dconf.settings = {
    # shell configuration depends on the user

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
