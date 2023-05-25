# helix.nix
{ config, lib, pkgs, ... }: {

  programs.helix = {
    enable = lib.mkDefault true;

    settings = {
      theme = "base16_transparent";
      editor.lsp.display-messages = true;
    };

    languages = {
      language-server.jdt-language-server = {
        command = "${pkgs.jdt-language-server}/bin/jdt-language-server";
        args = [
          "-configuration"
          "${config.xdg.cacheHome}/.jdt/jdtls_install/config_linux"
          "-data"
          "${config.xdg.cacheHome}/.jdt/jdtls_data"
        ];
      };
      language = [
        {
          name = "java";
          roots = [ "pom.xml" ];

          # temporary until helix release after 23.05
          language-server.command = "${pkgs.jdt-language-server}/bin/jdt-language-server";
          language-server.args = [
            "-configuration"
            "${config.xdg.cacheHome}/.jdt/jdtls_install/config_linux"
            "-data"
            "${config.xdg.cacheHome}/.jdt/jdtls_data"
          ];
        }
        {
          name = "yaml";
          config = {
            yaml.keyOrdering = false;
          };
        }
      ];
    };
  };

  home.sessionVariables.EDITOR = "hx";

  home.packages = lib.mkBefore ((with pkgs; [
    # wayland clipboard integration
    wl-clipboard
    # debugging
    lldb

    # Language support
    # go
    gopls
    # go debugging
    delve
    # java
    jdt-language-server
    # markdown
    marksman
    # nix
    nil
    # rust
    rust-analyzer
    # scala
    metals
    # toml
    taplo
    # vala
    vala-language-server
  ]) ++ (with pkgs.nodePackages; [
    # bash
    bash-language-server
    # dockerfile
    dockerfile-language-server-nodejs
    # typescript
    typescript-language-server
    # yaml
    yaml-language-server
  ]));

}

