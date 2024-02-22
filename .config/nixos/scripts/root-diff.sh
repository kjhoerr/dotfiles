#!/usr/bin/env bash
## Check current root for any files that are not persisted.
## (These files will be lost on a reboot.)
##
## This script makes some critical assumptions about how the filesystem has
## been created. Essentially, this supports two modes:
##
## - A LUKS partition containing a BTRFS partition
## - A LVM (can be contained in LUKS) that has a BTRFS partition
##
## There is also a root subvolume that is intended to be reset using a blank
## snapshot (root-blank).

if [ "$UID" -ne "0" ];
then
	>&2 echo "Must run as superuser to be able to mount main btrfs volume"
	exit 1
fi

MOUNTDIR=$(mktemp -d)
if [ -b /dev/pool/root ];
then
	BTRFS_VOL=/dev/pool/root
else
	BTRFS_VOL=/dev/mapper/enc
fi

if [ ! -r "$BTRFS_VOL" ];
then
	>&2 echo "Device '$BTRFS_VOL' not found"
	exit 1
fi

## Mount the btrfs root to a tmpdir so we can check the subvolumes for
## mismatching files.
mount -t btrfs -o subvol=/ ${BTRFS_VOL} "${MOUNTDIR}"

BLANK_ROOT_SNAPSHOT="${MOUNTDIR}/root-blank"
ROOT_SUBVOL="${MOUNTDIR}/root"
OLD_TRANSID=$(btrfs subvolume find-new "${BLANK_ROOT_SNAPSHOT}" 9999999 |
		awk '{print $NF}')

echo "These files differ from the root partition and will be" \
	"cleared on next boot:"
btrfs subvolume find-new "$ROOT_SUBVOL" "$OLD_TRANSID" |
	sed '$d' |
	cut -f17- -d' ' |
	sort |
	uniq |
	while read -r path;
	do
		path="/$path"
		if [ -L "$path" ];
		then
			: # The path is a symbolic link, so is probably handled by NixOS
		elif [ -d "$path" ];
		then
			: # The path is a directory; ignore
		else
			echo "$path"
		fi
	done

umount "$MOUNTDIR"
rm -r  "$MOUNTDIR"
