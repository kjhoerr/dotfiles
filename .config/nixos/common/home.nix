# home.nix
# Requires home-manager flake
{ lib, config, pkgs, ... }: {

  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.utf8";

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    desktopManager.gnome.enable = true;
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Add docker
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    appimage-run
    neovim
    kakoune
    yubikey-personalization
    gcc
    gnupg
    pinentry-gnome
    gnome.gnome-tweaks
    gnome.gpaste
    gnomeExtensions.gsconnect
    gnomeExtensions.tailscale-status
    gnomeExtensions.night-theme-switcher
  ];

  fonts.fonts = with pkgs; [
    ibm-plex
    merriweather
    nerdfonts
    noto-fonts
    noto-fonts-emoji
  ];

  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  services.fwupd.enable = true;
  programs.gpaste.enable = true;

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  home-manager.users.kjhoerr = {
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
  };

}

