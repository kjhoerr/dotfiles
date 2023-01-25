# home/common.nix
{ lib, pkgs, ... }: {

  nixpkgs.config.allowUnfree = true;
  # Workaround for https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (_: true);

  programs.home-manager.enable = lib.mkDefault true;
  programs.bash.enable = lib.mkDefault true;
  programs.bash.bashrcExtra = lib.mkDefault ''
    eval "$(starship init bash)"
  '';
  programs.git.enable = lib.mkDefault true;
  programs.git.package = lib.mkDefault pkgs.gitAndTools.gitFull;
  programs.git.userName = lib.mkDefault "Kevin J Hoerr";
  programs.git.userEmail = lib.mkDefault "kjhoerr@protonmail.com";
  programs.git.signing.key = lib.mkDefault "BEDBA29269ED7111";
  programs.git.signing.signByDefault = lib.mkDefault true;
  programs.git.extraConfig.init.defaultBranch = "trunk";
  programs.git.extraConfig.core.editor = "nvim";
  programs.git.extraConfig.color.ui = "always";
  programs.git.extraConfig.stash.showPatch = true;
  programs.git.extraConfig.pull.ff = "only";
  programs.git.extraConfig.push.autoSetupRemote = true;
  programs.neovim.enable = lib.mkDefault true;
  programs.neovim.vimAlias = lib.mkDefault true;
  programs.neovim.defaultEditor = lib.mkDefault true;
  programs.neovim.extraConfig = lib.mkDefault ''
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
  programs.neovim.plugins = lib.mkDefault (with pkgs.vimPlugins; [
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
  ]);

  programs.neovim.extraPackages = lib.mkDefault (with pkgs; [
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    hadolint
    nodePackages.vim-language-server
    shellcheck
    rnix-lsp
    deadnix
    statix
  ]);

  home.packages = lib.mkBefore (with pkgs; [
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
  ]);

  services.gnome-keyring.enable = lib.mkDefault false;
  services.gpg-agent.enable = lib.mkDefault true;
  services.gpg-agent.enableSshSupport = lib.mkDefault true;
  services.gpg-agent.enableExtraSocket = lib.mkDefault true;
  services.gpg-agent.pinentryFlavor = lib.mkDefault "gnome3";

}

