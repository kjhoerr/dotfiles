# neovim.nix
{ lib, ... }: {

  programs.neovim.enable = lib.mkDefault true;
  programs.neovim.vimAlias = lib.mkDefault true;
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
    endif
  '';

}

