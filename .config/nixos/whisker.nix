# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-whisker.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "whisker"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.firewall.checkReversePath = "loose";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
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

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kjhoerr = {
    isNormalUser = true;
    description = "Kevin Hoerr";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox-wayland
      caprine-bin
      bind
      discord-canary
      doctl
      keepassxc
      vscode
      k9s
      kubernetes-helm
      kubectl
      git
      starship
      pueue
      protonmail-bridge
      mkcert
      pfetch
      runelite
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Add docker
  virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    kakoune
    syncthing-tray
    yubikey-personalization
    gnupg
    pinentry-gnome
    gnomeExtensions.gsconnect
    gnomeExtensions.clipboard-history
    gnomeExtensions.tailscale-status
  ];
  
  fonts.fonts = with pkgs; [
    ibm-plex
    merriweather
    nerdfonts
    noto-fonts
    noto-fonts-emoji
  ];

  # Add env vars
  environment.sessionVariables.QT_QPA_PLATFORM = "wayland";
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  
  services.tailscale.enable = true;
  services.syncthing = {
    enable = true;
    user = "kjhoerr";
    dataDir = "/home/kjhoerr/Documents";
    configDir = "/home/kjhoerr/.config/syncthing";
  };
  
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.ssh.startAgent = false;
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];
  services.fwupd.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  #services.gnome3.gnome-keyring.enable = false;
  #programs.gpg.scdaemonSettings = { disable-ccid = true; };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
    export NIXOS_CONFIG="/home/kjhoerr/.config/nixos/whisker.nix"
  '';
  
  # udev 250 doesn't reliably reinitialize devices after restart
  systemd.services.systemd-udevd.restartIfChanged = false;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
  
  nix.settings.experimental-features = "nix-command flakes";

}
