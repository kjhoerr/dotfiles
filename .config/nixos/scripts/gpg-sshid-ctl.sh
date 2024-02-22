#!/usr/bin/env bash
## Enable or disable sshcontrol for a specific key or all keys when the SSH
## agent is controlled by GPG

SSHCONTROL_FILE=${SSHCONTROL_FILE:-~/.gnupg/sshcontrol}

command="${1:-}"
identity_file="${2:-}"
shift 2 || true

if [ ! -w "$SSHCONTROL_FILE" ];
then
	>&2 echo "GPG sshcontrol file $SSHCONTROL_FILE is not writable."
	exit 1
fi

if [ -n "$identity_file" ] && [ ! -r "$identity_file" ];
then
	>&2 echo "Identity file $identity_file is not readable."
	exit 1
fi

## Display expected usage of script
function usage {
	>&2 echo "Usage: $0 {enable|disable} [<ID file>]"
	exit 1
}

## Find and parse keygrip for keyfile provided
function find_keygrip {
	fingerprint_output=$(ssh-keygen -lf "$1")
	fingerprint=$(echo "$fingerprint_output" | awk '{print $2}')

	keygrip_output=$(gpg-connect-agent 'keyinfo --ssh-list --ssh-fpr' /bye)
	keygrip=$(echo "$keygrip_output" | grep "$fingerprint" | awk '{print $3}')
	echo "$keygrip"
	return
}

## Use sed to enable or disable a given keygrip or regex group in the
## SSHCONTROL_FILE.
function sshctrl {
	if [ -z "$3" ];
	then
		grip="[A-Z0-9]+"
	else
		grip="$3"
	fi

	sed -i -r "s/^$1($grip)/$2\1/" "$SSHCONTROL_FILE"
	return
}

## Parse identity_file for keygrip if it exists
keygrip=""
if [ -n "$identity_file" ] \
	&& ! keygrip=$(find_keygrip "$identity_file");
then
	>&2 echo "Error occurred while parsing keygrip"
	exit 1
fi

## Process command
if [ "$command" = "disable" ];
then
	sshctrl "" "!" "$keygrip"
	result=$?
elif [ "$command" = "enable" ];
then
	sshctrl "!" "" "$keygrip"
	result=$?
else
	usage
fi

## Process result status code for error
if [ "$result" -ne "0" ];
then
	>&2 echo "Error occurred while running $command sshcontrol."
	>&2 echo "Keygrip used: ${keygrip:-N/A}"
	exit 1
fi

## Output result
if [ -z "$keygrip" ];
then
	echo "All keys in $SSHCONTROL_FILE $command""d."
else
	echo "Identity file $identity_file (keygrip: $keygrip) $command""d."
fi
exit
