# home/kjhoerr.nix
# Requires home-manager flake
{ pkgs, ... }: {

  home.username = "kjhoerr";
  home.homeDirectory = "/home/kjhoerr";

  home.packages = with pkgs; [
    beeper
    doctl
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
    "yaml"
  ];

  dconf.settings = {
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
        "microsoft-edge-dev.desktop"
        "code.desktop"
        "beeper.desktop"
        "org.gnome.Nautilus.desktop"
        "com.raggesilver.BlackBox.desktop"
      ];
    };
  };

  home.stateVersion = "22.11";
}

