# persist.nix
# Requires impermanence flake
{ lib, config, pkgs, ... }: {

  boot.initrd.postMountCommands = lib.mkBefore ''
    ln -snfT /persist/etc/machine-id /etc/machine-id
    ln -snfT /persist/var/lib/NetworkManager/secret_key /var/lib/NetworkManager/secret_key
    ln -snfT /persist/var/lib/NetworkManager/seen-bssids /var/lib/NetworkManager/seen-bssids
    ln -snfT /persist/var/lib/NetworkManager/timestamps /var/lib/NetworkManager/timestamps
    ln -snfT /persist/var/lib/power-profiles-daemon/state.ini /var/lib/power-profiles-daemon/state.ini
  '';

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

}
