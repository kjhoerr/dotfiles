# helix.nix
{ config, lib, pkgs, ... }:
let
  # Override graalvm package with lower priority so jdk binaries can be selected
  # native-image still works great (at least with Quarkus)
  graalvm-ce-low = pkgs.graalvm-ce.overrideAttrs(oldAttrs: {
    meta.priority = 10;
  });
  lsp-enabled = lang: langconf: lib.mkIf (builtins.elem lang config.helix.lsps) langconf;
  lsp-package = lang: packages: if builtins.elem lang config.helix.lsps then packages else [];
in {

  options = {
    # To be declared in arbitrary user config. For example:
    #
    # helix.lsps = [ "bash" "css" "html" ];
    helix.lsps = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [
        "bash"
        "cmake"
        "css"
        "dockerfile"
        "go"
        "haskell"
        "html"
        "java"
        "json"
        "markdown"
        "nix"
        "python"
        "rust"
        "scala"
        "toml"
        "typescript"
        "vala"
        "yaml"
        "zig"
      ]);
    };
  };

  config.programs.helix = {
    enable = lib.mkDefault true;
    defaultEditor = lib.mkDefault true;

    settings = {
      theme = lib.mkDefault "base16_transparent";
      editor.lsp.display-messages = true;
      editor.true-color = true;
    };

    languages = {
      language-server.bash-language-server = lsp-enabled "bash" {
        command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
      };
      language-server.cmake-language-server = lsp-enabled "cmake" {
        command = "${pkgs.cmake-language-server}/bin/cmake-language-server";
      };
      language-server.vscode-css-language-server = lsp-enabled "css" {
        command = "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server";
      };
      language-server.docker-langserver = lsp-enabled "dockerfile" {
        command = "${pkgs.nodePackages.dockerfile-language-server-nodejs}/bin/docker-langserver";
      };
      language-server.gopls = lsp-enabled "go" {
        command = "${pkgs.gopls}/bin/gopls";
      };
      language-server.haskell-language-server = lsp-enabled "haskell" {
        command = "${pkgs.haskellPackages.haskell-language-server}/bin/haskell-language-server";
      };
      language-server.vscode-html-language-server = lsp-enabled "html" {
        command = "${pkgs.vscode-langservers-extracted}/bin/vscode-html-language-server";
      };
      language-server.jdtls = lsp-enabled "java" {
        command = "${pkgs.jdt-language-server}/bin/jdt-language-server";
        args = [
          "--jvm-arg=-javaagent:${pkgs.lombok}/share/java/lombok.jar"
          "-configuration"
          "${config.xdg.cacheHome}/.jdt/jdtls_install/config_linux"
          "-data"
          "${config.xdg.cacheHome}/.jdt/jdtls_data"
        ];
      };
      language-server.vscode-json-language-server = lsp-enabled "json" {
        command = "${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server";
      };
      language-server.marksman = lsp-enabled "markdown" {
        command = "${pkgs.marksman}/bin/marksman";
      };
      language-server.metals = lsp-enabled "scala" {
        command = "${pkgs.metals}/bin/metals";
      };
      language-server.nil = lsp-enabled "nix" {
        command = "${pkgs.nil}/bin/nil";
      };
      language-server.pylsp = lsp-enabled "python" {
        command = "${pkgs.python311Packages.python-lsp-server}/bin/pylsp";
      };
      language-server.rust-analyzer = lsp-enabled "rust" {
        command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      };
      language-server.taplo = lsp-enabled "toml" {
        command = "${pkgs.taplo}/bin/taplo";
      };
      language-server.typescript-language-server = lsp-enabled "typescript" {
        command = "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
      };
      language-server.vala-language-server = lsp-enabled "vala" {
        command = "${pkgs.vala-language-server}/bin/vala-language-server";
      };
      language-server.yaml-language-server = lsp-enabled "yaml" {
        command = "${pkgs.nodePackages.yaml-language-server}/bin/yaml-language-server";
        config = {
          yaml.keyOrdering = false;
        };
      };
      language-server.zls = lsp-enabled "zig" {
        command = "${pkgs.zls}/bin/zls";
      };
      language = [
        (lsp-enabled "java" {
          name = "java";
          roots = [ "pom.xml" ];
        })
      ];
    };

    themes = {
      # A theme oriented for light system theme with transparent background
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

  # For any configured languages, also add their build tools to home.packages
  config.home.packages = lib.mkBefore (with pkgs; [
    # debugging
    lldb
    # testing
    playwright-driver
  ]
    ++ (lsp-package "go" [ pkgs.delve ])
    ++ (lsp-package "java" [ graalvm-ce-low pkgs.maven ])
    ++ (lsp-package "typescript" [ pkgs.yarn-berry ])
  );

}

