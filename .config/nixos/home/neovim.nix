# neovim.nix
{ lib, pkgs, ... }: {

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

}

