# home.nix
# Requires home-manager flake
{ pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    firefox-wayland
    bind
    discord-canary
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
    runelite
  ];

  programs.bash = {
    enable = true;

    bashrcExtra = ''
      eval "$(starship init bash)"
    '';
  };
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Kevin J Hoerr";
    userEmail = "kjhoerr@protonmail.com";
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
  programs.home-manager.enable = true;
  programs.neovim = {
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

  services.syncthing = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryFlavor = "gnome3";
  };

  home.stateVersion = "22.11";

}

