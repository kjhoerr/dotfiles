#!/usr/bin/env bash
## Substitute for nixos-rebuild and home-manager that is better for
## coordinating joint updates to system/user profiles and is more compatible
## with more modern nix-commands options. Anything passed to this script is
## provided as option(s) to nix build

## Setup - strongly assume defaults
SOURCE="${FLAKE_SOURCE:-github:kjhoerr/dotfiles/hardened}"
SYSPROFILE="/nix/var/nix/profiles/system"
HOSTNAME=$(hostname)
USERNAME=$(whoami)

if [ "${FLAKE_SOURCE}" != "." ];
then
	cd "$(mktemp -d)" || exit
fi

## Build NixOS, home-manager profiles
if ! nix build "$@" \
	"${SOURCE}#nixosConfigurations.${HOSTNAME}.config.system.build.toplevel" \
	"${SOURCE}#homeConfigurations.${USERNAME}.activationPackage";
## Detect errors at build and fail out before profiles get activated
then
	>&2 echo "Error occurred while building NixOS and home-manager profiles"
	exit 1
fi

if [ ! -d ./result ] || [ ! -d ./result-1 ];
then
  exit 1
fi

echo
echo "User profile updates:"
nix store diff-closures ~/.nix-profile "$(readlink -f ./result-1/home-path)" \
  | grep -v "env-manifest.nix: ε → ∅" \
  | grep -v "user: ε → ∅"

echo
echo "System profile updates:"
nix store diff-closures $SYSPROFILE ./result
echo

read -r -p "Paused - enter to continue"

NEWSYSLINK=$(readlink -f ./result)

## Activate new profiles
## If either fails, the error will fall through the end of the script
doas nix-env --profile $SYSPROFILE --set "$NEWSYSLINK" \
 && doas ./result/bin/switch-to-configuration boot \
 && ./result-1/activate
exit

