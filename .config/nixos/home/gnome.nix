{ lib, ... }: {

  dconf.settings = {
    # shell configuration depends on the user

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      # All the below are installed at the system level
      # Could instead use `gtk.cursorTheme`, etc. and reference the actual packages
      cursor-theme = "capitaine-cursors";
      document-font-name = "Merriweather 11";
      font-name = "IBM Plex Sans Arabic 11";
      monospace-font-name = "FiraMono Nerd Font 10";
    };

    "com/raggesilver/BlackBox" = {
      style-preference = 2;
      opacity = 87;
      terminal-padding = lib.hm.gvariant.mkTuple [4 4 4 4];
      theme-dark = "Pencil Dark";
      use-sixel = true;
      floating-controls = true;
    };
  };

}
