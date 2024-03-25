# whisker.nix
{ pkgs, lib, ... }: {

  networking.hostName = "whisker";

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "tpm_tis" "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  
  fileSystems."/" =
    { device = "/dev/mapper/enc";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/cb549ee5-4e1c-4188-8906-312228068cc1";

  fileSystems."/home" =
    { device = "/dev/mapper/enc";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/mapper/enc";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/mapper/enc";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/dev/mapper/enc";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/EE18-049D";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/d4a415b7-048e-4db5-9621-d4c29a59f8d5"; }
    ];

  # disable unused ethernet interface
  networking.interfaces.enp7s0.useDHCP = false;

  hardware.cpu.amd.updateMicrocode = true;

  time.hardwareClockInLocalTime = true;

  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  users.mutableUsers = false;
  users.users.root.hashedPasswordFile = "/persist/passwords/root";
  users.users.kjhoerr = {
    isNormalUser = true;
    description = "Kevin Hoerr";
    extraGroups = [ "networkmanager" "wheel" ];
    hashedPasswordFile = "/persist/passwords/kjhoerr";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = lib.mkAfter (with pkgs; [
    lact
    lutris
  ]);

  services.mpd = {
    enable = true;
    fluidsynth = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
  
  nix.settings.experimental-features = "nix-command flakes";

}
