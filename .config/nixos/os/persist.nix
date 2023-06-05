# persist.nix
# Requires impermanence flake
{ lib, pkgs, ... }:
let
  root-diff = pkgs.writeShellScriptBin "root-diff" ''
    # Check current root for any files that are not persisted.
    # (These files will be lost on a reboot.)

    set -euo pipefail

    sudo mkdir -p /mnt/tmp-root

    # We first mount the btrfs root to /mnt/tmp-root
    # so we can check the subvolumes for mismatching files.
    # If LVM exists, mount that.
    if [[ -b /dev/pool/root ]]; then
      sudo mount -t btrfs -o subvol=/ /dev/pool/root /mnt/tmp-root
    else
      sudo mount -t btrfs -o subvol=/ /dev/mapper/enc /mnt/tmp-root
    fi

    OLD_TRANSID=$(sudo btrfs subvolume find-new /mnt/tmp-root/root-blank 9999999 | awk '{print $NF}')

    echo "These files differ from the root partition and will be cleared on next boot:"
    sudo btrfs subvolume find-new "/mnt/tmp-root/root" "$OLD_TRANSID" |
      sed '$d' |
      cut -f17- -d' ' |
      sort |
      uniq |
      while read path; do
        path="/$path"
        if [ -L "$path" ]; then
          : # The path is a symbolic link, so is probably handled by NixOS already
        elif [ -d "$path" ]; then
          : # The path is a directory; ignore
        else
          echo "$path"
        fi
      done

    sudo umount /mnt/tmp-root
  '';
in {

  boot.initrd.systemd.enable = lib.mkDefault true;
  boot.initrd.systemd.services.rollback = {
    description = "Rollback BTRFS root subvolume to a pristine state";
    wantedBy = [
      "initrd.target"
    ];
    after = [
      # LUKS/TPM process
      "systemd-cryptsetup@enc.service"
    ];
    before = [
      "sysroot.mount"
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt

      # Pick up any LVM from newly mapped enc
      vgscan
      vgchange -ay

      # We first mount the btrfs root to /mnt
      # so we can manipulate btrfs subvolumes.
      # If LVM exists, mount that.
      if [[ -b /dev/pool/root ]]; then
        mount -t btrfs -o subvol=/ /dev/pool/root /mnt
      else
        mount -t btrfs -o subvol=/ /dev/mapper/enc /mnt
      fi

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
  };
  boot.initrd.systemd.services.persisted-files = {
    description = "Hard-link persisted files from /persist";
    wantedBy = [
      "initrd.target"
    ];
    after = [
      "sysroot.mount"
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /sysroot/etc/
      ln -snfT /persist/etc/machine-id /sysroot/etc/machine-id
    '';
  };

  # symlinks to enable "erase your darlings"
  environment.persistence."/persist" = {
    directories = [
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
    files = [
      "/var/lib/NetworkManager/secret_key"
      "/var/lib/NetworkManager/seen-bssids"
      "/var/lib/NetworkManager/timestamps"
      "/var/lib/power-profiles-daemon/state.ini"
    ];
  };

  environment.systemPackages = lib.mkBefore [ root-diff ];

}
