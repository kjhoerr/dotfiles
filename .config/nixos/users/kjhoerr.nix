# home/kjhoerr.nix
# Requires home-manager flake
{ pkgs, ... }: {

  home.username = "kjhoerr";
  home.homeDirectory = "/home/kjhoerr";

  home.packages = with pkgs; [
    doctl
    mkcert
    runelite
    discord-canary
  ];

  services.syncthing.enable = true;
  services.pueue = {
    enable = true;
    settings = {
      client = {
        dark_mode = false;
        show_expanded_aliases = false;
      };
      daemon = {
        default_parallel_tasks = 2;
        pause_group_on_failure = false;
        pause_all_on_failure = false;
      };
      shared = {
        use_unix_socket = true;
      };
    };
  };

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
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
  };

  home.stateVersion = "22.11";
}

