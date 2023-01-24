# system.nix
# Common system configuration, flakeless
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

}

