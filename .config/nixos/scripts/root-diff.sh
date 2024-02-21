#!/usr/bin/env bash
## Check current root for any files that are not persisted.
## (These files will be lost on a reboot.)
##
## This script makes some critical assumptions about how the filesystem has
## been created. Essentially, this supports two modes:
##
## - A LUKS partition containing a BTRFS partition
## - A LVM (can be contained in LUKS) thas has a BTRFS partition
##
## There is a root subvolume that is intended to be reset to using a blank
## snapshot (root-blank).

set -euo pipefail

MOUNTDIR=$(mktemp -d)
BLANK_ROOT_SNAPSHOT="${MOUNTDIR}/root-blank"
if [[ -b /dev/pool/root ]];
then
	BTRFS_VOL=/dev/pool/root
else
	BTRFS_VOL=/dev/mapper/enc
fi

## Mount the btrfs root to a tmpdir so we can check the subvolumes for
## mismatching files.
mount -t btrfs -o subvol=/ ${BTRFS_VOL} "${MOUNTDIR}"

OLD_TRANSID=$(btrfs subvolume find-new "${BLANK_ROOT_SNAPSHOT}" 9999999 \
		| awk '{print $NF}')

echo "These files differ from the root partition and will be cleared on next" \
	" boot:"
btrfs subvolume find-new "$MOUNTDIR/root" "$OLD_TRANSID" |
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
