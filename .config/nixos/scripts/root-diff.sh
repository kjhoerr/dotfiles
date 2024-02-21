#!/usr/bin/env bash
# Check current root for any files that are not persisted.
# (These files will be lost on a reboot.)

set -euo pipefail

mkdir -p /mnt/tmp-root

# We first mount the btrfs root to /mnt/tmp-root
# so we can check the subvolumes for mismatching files.
# If LVM exists, mount that.
if [[ -b /dev/pool/root ]]; then
  mount -t btrfs -o subvol=/ /dev/pool/root /mnt/tmp-root
else
  mount -t btrfs -o subvol=/ /dev/mapper/enc /mnt/tmp-root
fi

OLD_TRANSID=$(btrfs subvolume find-new /mnt/tmp-root/root-blank 9999999 | awk '{print $NF}')

echo "These files differ from the root partition and will be cleared on next boot:"
btrfs subvolume find-new "/mnt/tmp-root/root" "$OLD_TRANSID" |
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

umount /mnt/tmp-root
