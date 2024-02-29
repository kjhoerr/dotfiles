# disko.nix
# Requires disko flake
{
  disko.devices = {
    disk.disk0 = {
      device = "/dev/nvme0n1";
      type = "disk";
      content.type = "gpt";
      content.partitions = {
        ESP = {
          type = "EF00";
          size = "1024M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        LUKS = {
          size = "100%";
          content = {
            type = "luks";
            name = "enc";
            ## e.g. `read -sp "Enter LUKS passphrase: " lukspp && echo -n "$lukspp" > /persist/passwords/system-luks.key`
            #passwordFile = "/persist/passwords/system-luks.key";
            settings.allowDiscards = true;
            content = {
              type = "lvm_pv";
              vg = "root";
            };
          };
        };
      };
    };
    lvm_vg.root = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = "68G";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        };
        btrrt = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/root" = {
                mountOptions = [ "compress=zstd" "noatime" ];
                mountpoint = "/";
              };
              "/home" = {
                mountOptions = [ "compress=zstd" "noatime" ];
                mountpoint = "/home";
              };
              "/nix" = {
                mountOptions = [ "compress=zstd" "noatime" ];
                mountpoint = "/nix";
              };
              "/persist" = {
                mountOptions = [ "compress=zstd" "noatime" ];
                mountpoint = "/persist";
              };
              "/log" = {
                mountOptions = [ "compress=zstd" "noatime" ];
                mountpoint = "/var/log";
              };
            };
            mountpoint = "/dev/pool/root";
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
