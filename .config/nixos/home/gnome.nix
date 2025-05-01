{ lib, pkgs, ... }:
let
  mkUint32 = lib.hm.gvariant.mkUint32;
  mkTuple = lib.hm.gvariant.mkTuple; 
in {

  dconf.settings = {
    # shell configuration depends on the user

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      # All the below are installed at the system level
      # Could instead use `gtk.cursorTheme`, etc. and reference the actual packages
      cursor-theme = "capitaine-cursors";
      document-font-name = "Merriweather 11";
      font-name = "IBM Plex Sans Arabic 11";
      icon-theme = "Adwaita";
      monospace-font-name = "FiraCode Nerd Font 10";
    };

    "com/raggesilver/BlackBox" = {
      style-preference = mkUint32 2;
      opacity = mkUint32 87;
      terminal-padding = mkTuple [(mkUint32 4) (mkUint32 4) (mkUint32 4) (mkUint32 4)];
      theme-dark = "Pencil Dark";
      use-sixel = true;
      floating-controls = true;
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      sigma = 55;
      brightness = 0.60;
      color = mkTuple [ 0.0 0.0 0.0 0.31 ];
      noise-amount = 0.55;
      noise-lightness = 1.25;
    };
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      dynamic-opacity = false;
      blur = true;
      blur-on-overview = true;
      opacity = 210;
      whitelist = [ "com.raggesilver.BlackBox" ];
    };
  };

  # Enable gnome-keyring - omit gnome-keyring-ssh
  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" ];
  };

  services.gpg-agent.pinentry.package = lib.mkDefault pkgs.pinentry-gnome3;

}
