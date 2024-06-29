# home/kjhoerr.nix
# Requires home-manager flake
{ pkgs, ... }:
let
  elem-wp-path = "${pkgs.pantheon.elementary-wallpapers}/share/backgrounds";
in {

  home.username = "kjhoerr";
  home.homeDirectory = "/home/kjhoerr";

  home.packages = with pkgs; [
    beeper
    doctl
    flatpak-builder
    mkcert
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

  helix.lsps = [
    "bash"
    "css"
    "dockerfile"
    "html"
    "java"
    "json"
    "markdown"
    "nix"
    "rust"
    "toml"
    "typescript"
    "vala"
    "yaml"
  ];

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "${elem-wp-path}/odin.jpg";
      picture-uri-dark = "${elem-wp-path}/odin-dark.jpg";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "gsconnect@andyholmes.github.io"
        "tailscale@joaophi.github.com"
        "nightthemeswitcher@romainvigier.fr"
        "GPaste@gnome-shell-extensions.gnome.org"
        "blur-my-shell@aunetx"
        "luminus-shell-y@dikasp.gitlab"
      ];
      favorite-apps = [
        "chromium-browser.desktop"
        "code.desktop"
        "beeper.desktop"
        "org.gnome.Nautilus.desktop"
        "com.raggesilver.BlackBox.desktop"
      ];
    };
  };

  home.stateVersion = "22.11";
}

