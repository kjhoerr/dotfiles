#!/usr/bin/env bash
## Reset current root to clear any files that are not persisted.
## This is built to run during stage-0 (see persist.nix rollback service).
##
## This script makes some critical assumptions about how the filesystem has
## been created. Essentially this supports two modes:
##
## - A LUKS partition containing a BTRFS partition
## - A LVM (can be contained in LUKS) that has a BTRFS partition
##
## There is also a root subvolume that this script resets using a blank
## snapshot (root-blank).

if [ "$UID" -ne "0" ];
then
	>&2 echo "Must run as superuser to be able to mount and" \
		"manipulate btrfs root subvolume"
	exit 1
fi

MOUNTDIR=/mnt
mkdir -p ${MOUNTDIR}

# Pick up any LVM from newly mapped enc
vgscan
vgchange -ay

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

# We first mount the btrfs root to /mnt
# so we can manipulate btrfs subvolumes.
mount -t btrfs -o subvol=/ ${BTRFS_VOL} ${MOUNTDIR}

BLANK_ROOT_SNAPSHOT="${MOUNTDIR}/root-blank"
ROOT_SUBVOL="${MOUNTDIR}/root"

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
btrfs subvolume list -o ${ROOT_SUBVOL} |
	cut -f9 -d' ' |
	while read -r subvolume;
	do
		echo "deleting /$subvolume subvolume..."
		btrfs subvolume delete "${MOUNTDIR}/$subvolume"
	done &&
	echo "deleting /root subvolume..." &&
	btrfs subvolume delete ${ROOT_SUBVOL}

echo "restoring blank /root subvolume..."
btrfs subvolume snapshot ${BLANK_ROOT_SNAPSHOT} ${ROOT_SUBVOL}

# Once we're done rolling back to a blank snapshot,
# we can unmount /mnt and continue on the boot process.
umount ${MOUNTDIR}
