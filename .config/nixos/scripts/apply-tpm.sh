#!/usr/bin/env bash
## Writes the LUKS key to the TPM with preset PCRs 0+2+7.
##
## If a disk is not specified, then the script will try to automatically find
## it from the system devices.

PCRS="${OVERRIDE_PCRS:-0+2+7}"

function usage {
	>&2 echo "Usage: $0 [LUKS partition]"
	exit 1
}

if [ -z "${1}" ];
then
	partuuid="$(lsblk -o fstype,uuid | grep 'crypto_LUKS' | awk '{print $2;}')"
	lukspath="$(readlink -f /dev/disk/by-uuid/"${partuuid}")"
elif [ -b "${1}" ];
then
  lukspath="${1}"
else
  usage
fi

if ! cryptsetup isLuks -v "${lukspath}";
then
  >&2 echo "Partition is not LUKS or is not accessible (selected partition: ${lukspath})"
  >&2 echo
	usage
fi

echo "Using LUKS partition: ${lukspath}"
echo "Selected PCRs: ${PCRS}"
echo

systemd-cryptenroll "${lukspath}" \
    --wipe-slot=tpm2 \
    --tpm2-device=auto \
    --tpm2-pcrs="${PCRS}"
exit

