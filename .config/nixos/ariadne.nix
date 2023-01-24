# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }: {
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "boot.shell_on_fail"
  ];
  boot.consoleLogLevel = 0;
  boot.supportedFilesystems = [ "btrfs" ];
  hardware.enableAllFirmware = true;

  boot.plymouth.enable = true;

  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;
  boot.initrd.postMountCommands = lib.mkBefore ''
    ln -snfT /persist/etc/machine-id /etc/machine-id
    ln -snfT /persist/var/lib/NetworkManager/secret_key /var/lib/NetworkManager/secret_key
    ln -snfT /persist/var/lib/NetworkManager/seen-bssids /var/lib/NetworkManager/seen-bssids
    ln -snfT /persist/var/lib/NetworkManager/timestamps /var/lib/NetworkManager/timestamps
    ln -snfT /persist/var/lib/power-profiles-daemon/state.ini /var/lib/power-profiles-daemon/state.ini
  '';

  boot.bootspec.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  security.tpm2.enable = true;
  security.tpm2.tctiEnvironment.enable = true;

  # No swap is configured at present - 
  #services.logind = {
  #  lidSwitch = "suspend-then-hibernate";
  #  extraConfig = ''
  #    HandlePowerKey=suspend-then-hibernate
  #    IdleAction=suspend-then-hibernate
  #    IdleActionSec=2m
  #  '';
  #};
  #systemd.sleep.extraConfig = "HibernateDelaySec=30min";

  networking.hostName = "ariadne";
  networking.networkmanager.enable = true;

  # Set your time zone.
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
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.mutter]
      experimental-features=['scale-monitor-framebuffer']
    '';
    extraGSettingsOverridePackages = [ pkgs.gnome.mutter ];
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.root.passwordFile = "/persist/passwords/root";
  users.users.kjhoerr = {
    isNormalUser = true;
    description = "Kevin Hoerr";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    passwordFile = "/persist/passwords/kjhoerr";
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
    tpm2-tss
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

  services.tailscale.enable = true;
  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ];
  programs.gpaste.enable = true;

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  '';

  # symlinks to enable "erase your darlings"
  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
      "/etc/secureboot"
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/colord"
      "/var/lib/docker"
      "/var/lib/fprint"
      "/var/lib/tailscale"
      "/var/lib/upower"
      "/var/lib/systemd/coredump"
    ];
  };
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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.checkReversePath = "loose";

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  nix.settings.experimental-features = "nix-command flakes";

}

