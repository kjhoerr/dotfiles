# cronos.nix
{ config, lib, pkgs, ... }: {

  networking.hostName = "cronos";

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "tpm_tis" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e7801e57-5291-4c9a-beb7-1dc31a071023";
    fsType = "btrfs";
    options = [ "subvol=root" "compress=zstd" "noatime" ];
    };

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/5ccdb8cb-4ffa-4798-b091-cdb2398acb28";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/e7801e57-5291-4c9a-beb7-1dc31a071023";
      fsType = "btrfs";
      options = [ "subvol=home" "compress=zstd" "noatime" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/e7801e57-5291-4c9a-beb7-1dc31a071023";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd" "noatime" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/e7801e57-5291-4c9a-beb7-1dc31a071023";
      fsType = "btrfs";
      options = [ "subvol=persist" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/e7801e57-5291-4c9a-beb7-1dc31a071023";
      fsType = "btrfs";
      options = [ "subvol=log" "compress=zstd" "noatime" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AA17-F965";
      fsType = "vfat";
    };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  # Turn off fprint - authentication is persisted
  services.fprintd.enable = false;

  # User accounts
  users.mutableUsers = false;
  users.users.root.passwordFile = "/persist/passwords/root";
  users.users.khoerr = {
    isNormalUser = true;
    description = "Kevin Hoerr";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    passwordFile = "/persist/passwords/khoerr";
  };
  
  home-manager.users.khoerr = import ./common/home.nix;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  nix.settings.experimental-features = "nix-command flakes";
}
