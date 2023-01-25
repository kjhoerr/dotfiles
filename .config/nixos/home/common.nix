# home/common.nix
{ lib, pkgs, ... }: {

  nixpkgs.config = {
    allowUnfree = true;
    # Workaround for https://github.com/nix-community/home-manager/issues/2942
    allowUnfreePredicate = (_: true);
  };

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;

      bashrcExtra = ''
        eval "$(starship init bash)"
      '';
    };
    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "Kevin J Hoerr";
      userEmail = lib.mkDefault "kjhoerr@protonmail.com";
      signing = {
        key = "BEDBA29269ED7111";
        signByDefault = true;
      };
      extraConfig = {
        init.defaultBranch = "trunk";
        core.editor = "nvim";
        color.ui = "always";
        stash.showPatch = true;
        pull.ff = "only";
        push.autoSetupRemote = true;
      };
    };
    neovim = {
      enable = true;
      vimAlias = true;
      defaultEditor = true;
      extraConfig = ''
        set nocompatible
        set showmatch
        set ignorecase
        set hlsearch
        set incsearch
        set number
        set expandtab
        set wildmode=longest,list
        filetype plugin indent on
        if !exists('g:vscode')
          syntax on
          set mouse=a
          cmap w!! w !sudo tee > /dev/null %
          colorscheme dracula
        endif
      '';
      plugins = with pkgs.vimPlugins; [
        bufferline-nvim
        dracula-vim
        nvim-colorizer-lua
        nvim-tree-lua
        tokyonight-nvim
        telescope-fzf-native-nvim
        telescope-nvim
        gitsigns-nvim
        (nvim-treesitter.withPlugins (plugins: with plugins; [
          tree-sitter-bash
          tree-sitter-dockerfile
          tree-sitter-html
          tree-sitter-java
          tree-sitter-javascript
          tree-sitter-json
          tree-sitter-markdown
          tree-sitter-nix
          tree-sitter-regex
        ]))
      ];

      extraPackages = with pkgs; [
        nodePackages.bash-language-server
        nodePackages.dockerfile-language-server-nodejs
        hadolint
        nodePackages.vim-language-server
        shellcheck
        rnix-lsp
        deadnix
        statix
      ];
    };
  };

  packages = with pkgs; [
    firefox-wayland
    bind
    doctl
    keepassxc
    vscode
    k9s
    kubernetes-helm
    kubectl
    starship
    pueue
    mkcert
    pfetch
  ];

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      pinentryFlavor = "gnome3";
    };
  };

}

