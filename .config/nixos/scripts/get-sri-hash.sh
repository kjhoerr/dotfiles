#!/usr/bin/env bash
## Uses nix to prefetch an archive from an external source and output the
## sha256 SRI hash of the archive that would be used for hash verification
## of the source.

function usage {
	>&2 echo "Usage: $0 <archive URL>"
	exit 1
}

repo_archive="${1:-}"

if [ -z "$repo_archive" ];
then
	usage
fi

prefetch_path=$(nix-prefetch-url --unpack --print-path "$repo_archive" |
	grep '/nix/store')

nix-hash --type sha256 --sri "$prefetch_path"
exit
