#!/usr/bin/env bash
## Substitute for nixos-rebuild and home-manager that is better for
## coordinating joint updates to system/user profiles and is more compatible
## with more modern nix-commands options. Anything passed to this script is
## provided as option(s) to nix build

## Setup - strongly assume defaults
SOURCE="github:kjhoerr/dotfiles"
HOSTNAME=$(hostname)
USERNAME=$(whoami)
cd "$(mktemp -d)" || exit

## Build NixOS, home-manager profiles
if ! nix build "$@" \
	"${SOURCE}#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel" \
	"${SOURCE}#homeConfigurations.${USERNAME}.activationPackage";
## Detect errors at build and fail out before profiles get activated
then
	>&2 echo "Error occurred while building NixOS and home-manager profiles"
	exit 1
fi

## Activate new profiles
## If either fails, the error will fall through the end of the script
./result-1/activate \
 && sudo ./result/bin/switch-to-configuration boot
exit

