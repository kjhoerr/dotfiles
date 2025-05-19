# system.nix
# Common system configuration
{ lib, pkgs, ... }:
let
  get-sri-hash = pkgs.writeShellApplication {
    name = "get-sri-hash";
    text = builtins.readFile ../scripts/get-sri-hash.sh;
  };
in {

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.utf8";

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;

  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = lib.mkDefault true;
      wayland = true;
    };
    desktopManager.gnome.enable = lib.mkDefault true;
  };
  services.displayManager = {
    defaultSession = "gnome";
  };
  services.desktopManager = {
    plasma6.enable = lib.mkDefault false;
  };
  programs.ssh.askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
  programs.zsh.enable = lib.mkDefault true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound using pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = (with pkgs; [
    appimage-run
    dmidecode
    get-sri-hash
    neovim
    kakoune
    yubikey-personalization
    gcc
    gnupg
    capitaine-cursors
    pciutils
    sbctl
    pinentry-gnome3
    podman-compose
    podman-desktop
    wl-clipboard
    gnome-tweaks
    gnome-boxes
  ]) ++ (with pkgs.gnomeExtensions; [
    blur-my-shell
    gsconnect
    luminus-shell-y
    night-theme-switcher
    tailscale-qs
  ]);

  # Remove unused/icky packages
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gedit
    gnome-contacts
    gnome-music
  ];
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Any packages for root that would otherwise be in home-manager
  users.users.root.packages = with pkgs; [
    bind
    git
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      ibm-plex
      merriweather
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "FiraCode" "UbuntuMono" "CascadiaCode" "Noto" ]; })
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Merriweather" ];
        sansSerif = [ "IBM Plex Sans" ];
        monospace = [ "FiraCode" "CascadiaCode" ];
      };

      antialias = true;
      subpixel = {
        rgba = "none";
        lcdfilter = "none";
      };
    };
  };

  # OCI engine
  virtualisation.podman = {
    enable = lib.mkDefault true;
    dockerSocket.enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # libvert
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  # Wayland-specific configuration
  environment.sessionVariables = {
    # keepassxc / QT apps will use xwayland by default - override
    QT_QPA_PLATFORM = "wayland";
    # Ensure Electron / "Ozone platform" apps enable using wayland in NixOS
    NIXOS_OZONE_WL = "1";
  };

  # Force gnome-keyring to disable, because it likes to bully gpg-agent
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  services.fwupd.enable = true;
  services.flatpak.enable = true;

  # gpaste has a daemon, must be enabled over package
  programs.gpaste.enable = true;

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

}

