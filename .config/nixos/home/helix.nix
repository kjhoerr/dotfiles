# helix.nix
{ lib, pkgs, ... }: {

  programs.helix = {
    enable = lib.mkDefault true;

    settings = {
      theme = "base16_transparent";
      editor.lsp.display-messages = true;
    };

    languages = [
      {
        name = "java";
        roots = [ "pom.xml" ];

        # Will create .jdt folder in project root... No way to map to user cache with hardcoding
        # Could map to /tmp but might cause issues after reboot
        language-server.command = "jdt-language-server";
        language-server.args = [
          "-configuration"
          ".jdt/jdtls_install/config_linux"
          "-data"
          ".jdt/jdtls_data"
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

