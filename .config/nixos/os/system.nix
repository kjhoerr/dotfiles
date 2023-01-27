# system.nix
# Common system configuration, flakeless
{ lib, config, pkgs, ... }: {

  # Enable automatic updates through this flake
  system.autoUpgrade = {
    enable = true;
    flake = "github:kjhoerr/dotfiles";
  };

  # Since automatic updates are enabled, automatically gc older generations
  # To note, this will gc home-manager user profiles as well
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.utf8";

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound using pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    appimage-run
    neovim
    kakoune
    yubikey-personalization
    gcc
    gnupg
    capitaine-cursors
    pinentry-gnome
    gnome.gnome-tweaks
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

  # Add Docker
  virtualisation.docker.enable = true;

  # Wayland-specific configuration
  services.xserver.displayManager.gdm.wayland = true;
  environment.sessionVariables = {
    # keepassxc / QT apps will use xwayland by default - override
    QT_QPA_PLATFORM = "wayland";
    # Ensure Electron / "Ozone platform" apps enable using wayland in NixOS
    NIXOS_OZONE_WL = "1";
  };

  # Force gnome-keyring to disable, because it likes to bully gpg-agent
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Enable fwupd - does not work well with lanzaboote at the moment
  services.fwupd.enable = true;

  # gpaste has a daemon, must be enabled over package
  programs.gpaste.enable = true;

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

}

