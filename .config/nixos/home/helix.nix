# helix.nix
{ config, lib, pkgs, ... }: {

  programs.helix = {
    enable = lib.mkDefault true;

    settings = {
      theme = lib.mkDefault "base16_transparent";
      editor.lsp.display-messages = true;
      editor.true-color = true;
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

    themes = {
      base16_ltrans = {
        "ui.background" = { fg = "black"; };
        "ui.background.separator" = { fg = "gray"; };
        "ui.text" = { fg = "black"; };
        "ui.text.focus" = { fg = "black"; };
        "ui.menu" = "none";
        "ui.menu.selected" = { modifiers = ["reversed"]; };
        "ui.menu.scroll" = { fg = "gray"; };
        "ui.linenr" = { fg = "gray"; };
        "ui.linenr.selected" = { fg = "black"; modifiers = ["bold"]; };
        "ui.popup" = { fg = "gray"; };
        "ui.window" = { fg = "gray"; };
        "ui.selection" = { bg = "gray"; };
        "comment" = "gray";
        "ui.statusline" = { fg = "black"; };
        "ui.statusline.inactive" = { fg = "gray"; };
        "ui.statusline.normal" = { fg = "black"; bg = "blue"; };
        "ui.statusline.insert" = { fg = "black"; bg = "green"; };
        "ui.statusline.select" = { fg = "black"; bg = "magenta"; };
        "ui.help" = { fg = "gray"; };
        "ui.cursor" = { modifiers = ["reversed"]; };
        "ui.cursor.match" = { fg = "light-yellow"; underline = { color = "light-yellow"; style = "line"; }; };
        "ui.cursor.primary" = { modifiers = ["reversed" "slow_blink"]; };
        "ui.cursor.secondary" = { modifiers = ["reversed"]; };
        "ui.virtual.ruler" = { bg = "gray"; };
        "ui.virtual.whitespace" = "gray";
        "ui.virtual.indent-guide" = "gray";
        "ui.virtual.inlay-hint" = { fg = "black"; bg = "gray"; };
        "ui.virtual.inlay-hint.parameter" = { fg = "black"; bg = "gray"; };
        "ui.virtual.inlay-hint.type" = { fg = "black"; bg = "gray"; };
        "ui.virtual.wrap" = "gray";

        "variable" = "light-red";
        "constant.numeric" = "yellow";
        "constant" = "yellow";
        "attribute" = "yellow";
        "type" = "light-yellow";
        "string" = "light-green";
        "variable.other.member" = "green";
        "constant.character.escape" = "light-cyan";
        "function" = "light-blue";
        "constructor" = "light-blue";
        "special" = "light-blue";
        "keyword" = "light-magenta";
        "label" = "light-magenta";
        "namespace" = "light-magenta";

        "markup.heading" = "light-blue";
        "markup.list" = "light-red";
        "markup.bold" = { fg = "light-yellow"; modifiers = ["bold"]; };
        "markup.italic" = { fg = "light-magenta"; modfiers = ["italic"]; };
        "markup.strikethrough" = { modifiers = ["crossed_out"]; };
        "markup.link.url" = { fg = "yellow"; underline = { color = "yellow"; style = "line"; }; };
        "markup.link.text" = "light-red";
        "markup.quote" = "light-cyan";
        "markup.raw" = "green";
        "markup.normal" = { fg = "blue"; };
        "markup.insert" = { fg = "green"; };
        "markup.select" = { fg = "magenta"; };

        "diff.plus" = "light-green";
        "diff.delta" = "light-blue";
        "diff.delta.moved" = "blue";
        "diff.minus" = "light-red";

        "ui.gutter" = "gray";
        "info" = "light-blue";
        "hint" = "light-gray";
        "debug" = "light-gray";
        "warning" = "light-yellow";
        "error" = "light-red";

        "diagnostic.info" = { underline = { color = "light-blue"; style = "dotted"; }; };
        "diagnostic.hint" = { underline = { color = "light-gray"; style = "double_line"; }; };
        "diagnostic.debug" = { underline = { color = "light-gray"; style = "dashed"; }; };
        "diagnostic.warning" = { underline = { color = "light-yellow"; style = "curl"; }; };
        "diagnostic.error" = { underline = { color = "light-red"; style = "curl"; }; };
      };
    };
  };

  home.sessionVariables.EDITOR = "hx";

  home.packages = lib.mkBefore ((with pkgs; [
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
    rnix-lsp
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

