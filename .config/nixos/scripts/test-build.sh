#!/usr/bin/env bash
# Helper script to build a local or remote flake. Defaults to current directory.

function usage {
	echo "Usage: $0 <user|system> <name of user or system> [additional options for nix build]"
	echo "FLAKE_SOURCE is an environment variable that is used to identify which repository should be used to build the flake."
	echo
	echo "Examples:"
	echo "$0 user percy"
	echo "$0 system whisker --substituters https://nix-community.cachix.org"
}

## Setup - strongly assume defaults
FLAKE_SOURCE="${FLAKE_SOURCE:-.}"

## Input
if [ "$1" != "user" ] && [ "$1" != "system" ];
then
  usage
  exit 1
fi
sysoruser="${1}"
sysuserid="${2}"
shift 2

if [ "${FLAKE_SOURCE}" != "." ];
then
	TMPDIR="$(mktemp -d)"
	cd "$TMPDIR" || exit
	echo "Resultant build will be at the following directory: ${TMPDIR}"
fi

if [ "${sysoruser}" = "system" ];
then
	buildString="${FLAKE_SOURCE}#nixosConfigurations.${sysuserid}.config.system.build.toplevel"
else
  buildString="${FLAKE_SOURCE}#homeConfigurations.${sysuserid}.activationPackage"
fi

nix build "${buildString}" "$@"
exit

