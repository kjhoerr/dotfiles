# ariadne.nix
# Requires impermanence flake
{ config, lib, pkgs, modulesPath, ... }: {

  networking.hostName = "ariadne";

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "tpm_tis" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  
  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt

    # We first mount the btrfs root to /mnt
    # so we can manipulate btrfs subvolumes.
    mount -o subvol=/ /dev/mapper/enc /mnt

    # While we're tempted to just delete /root and create
    # a new snapshot from /root-blank, /root is already
    # populated at this point with a number of subvolumes,
    # which makes `btrfs subvolume delete` fail.
    # So, we remove them first.
    #
    # /root contains subvolumes:
    # - /root/var/lib/portables
    # - /root/var/lib/machines
    #
    # I suspect these are related to systemd-nspawn, but
    # since I don't use it I'm not 100% sure.
    # Anyhow, deleting these subvolumes hasn't resulted
    # in any issues so far, except for fairly
    # benign-looking errors from systemd-tmpfiles.
    btrfs subvolume list -o /mnt/root |
      cut -f9 -d' ' |
      while read subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "/mnt/$subvolume"
      done &&
      echo "deleting /root subvolume..." &&
      btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    # Once we're done rolling back to a blank snapshot,
    # we can unmount /mnt and continue on the boot process.
    umount /mnt
  '';

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/683ba586-d4cc-4e75-bfd4-edf674ee6a78";
      fsType = "btrfs";
      options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/0ab7fa69-80bd-449e-8d45-bdc91d72af96";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/683ba586-d4cc-4e75-bfd4-edf674ee6a78";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/683ba586-d4cc-4e75-bfd4-edf674ee6a78";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/683ba586-d4cc-4e75-bfd4-edf674ee6a78";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" ];
      neededForBoot=true;
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/683ba586-d4cc-4e75-bfd4-edf674ee6a78";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" ];
      neededForBoot=true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/60E1-4324";
      fsType = "vfat";
    };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  # Enable fractional scaling
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverrides = ''
      [org.gnome.mutter]
      experimental-features=['scale-monitor-framebuffer']
    '';
    extraGSettingsOverridePackages = [ pkgs.gnome.mutter ];
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

  services.tailscale.enable = true;
  services.fwupd.extraRemotes = [ "lvfs-testing" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  nix.settings.experimental-features = "nix-command flakes";
}
