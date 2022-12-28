# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-whisker.nix
    ];

  # Bootloader.
  time.hardwareClockInLocalTime = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    # despite what the configuration.nix manpage seems to indicate,
    # as of release 17.09, setting device to "nodev" will still call
    # `grub-install` if efiSupport is true
    # (the devices list is not used by the EFI grub install,
    # but must be set to some value in order to pass an assert in grub.nix)
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
    enable = true;
    # set $FS_UUID to the UUID of the EFI partition
    #extraEntries = ''
    #  menuentry "Windows 11" {
    #    insmod part_gpt
    #    insmod fat
    #    insmod search_fs_uuid
    #    insmod chain
    #    search --fs-uuid --set=root 569D-4A46
    #    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    #  }
    #'';
    version = 2;
    useOSProber = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "whisker"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.interfaces.enp9s0.useDHCP = false;

  # Set your time zone.
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.utf8";

  # Enable the GNOME Desktop Environment with wayland.
  services.xserver.enable = true;
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
  };

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
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
    NIXOS_CONFIG = "/home/kjhoerr/.config/nixos/whisker.nix";
  };
  
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
  # Enable in support of Framework laptop firmware updates
  #environment.etc = {
  #  # recommended by framework for firmware 3.10
  #  "fwupd/uefi_capsule.conf" = lib.mkForce {
  #    source = pkgs.runCommand "fwupd-uefi-capsule-update-on-disk-disable.conf" { } ''
  #      sed "s,^#DisableCapsuleUpdateOnDisk=true,DisableCapsuleUpdateOnDisk=true," \
  #      "${pkgs.fwupd}/etc/fwupd/uefi_capsule.conf" > "$out"
  #    '';
  #  };
  #};

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
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  '';
  
  # udev 250 doesn't reliably reinitialize devices after restart
  systemd.services.systemd-udevd.restartIfChanged = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.checkReversePath = "loose";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
  
  nix.settings.experimental-features = "nix-command flakes";

}
