# home.nix
# Requires home-manager flake
{ lib, config, pkgs, ... }: {

  boot.initrd.postMountCommands = lib.mkBefore ''
    ln -snfT /persist/etc/machine-id /etc/machine-id
    ln -snfT /persist/var/lib/NetworkManager/secret_key /var/lib/NetworkManager/secret_key
    ln -snfT /persist/var/lib/NetworkManager/seen-bssids /var/lib/NetworkManager/seen-bssids
    ln -snfT /persist/var/lib/NetworkManager/timestamps /var/lib/NetworkManager/timestamps
    ln -snfT /persist/var/lib/power-profiles-daemon/state.ini /var/lib/power-profiles-daemon/state.ini
  '';

  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
  };
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

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
    syncthing-tray
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

