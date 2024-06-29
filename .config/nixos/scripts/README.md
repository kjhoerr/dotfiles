# NixOS Scripts

These scripts are used or are available for use through NixOS or home-manager
configurations as enabled through specific user/system modules.

These scripts can be executed standalone, though as enabled through their
modules may have dependencies that are not checked in the scripts themselves.

## apply-tpm.sh

This script assists in writing a LUKS passphrase into the TPM using PCRs.
By default the PCRs that are selected are `0+2+7`. These can be overridden
using the `OVERRIDE_PCRS` environment variable.

There are two dependencies, `systemd` and `cryptsetup`, which should be
already be available if this script is included from context of the
secure-boot module.

This script is included via the [`os/secure-boot.nix`](../os/secure-boot.nix)
module.

### Examples

```bash
apply-tpm

# Select a specific disk to unlock with TPM; use a lighter PCR policy
OVERRIDE_PCRS=0+7 apply-tpm /dev/nvme0n1p3
```

## get-sri-hash.sh

This script prefetches an archive for an external source and outputs the
sha256 SRI hash that is used by Nix to verify an archive matches the sha256
hash specified in a package's src declaration.

There are two dependencies, `nix-prefetch-url` and `nix-hash`, which should be
available on any system that has nix installed.

This script is included via the [`os/system.nix`](../os/system.nix) module.

### Examples

```bash
get-sri-hash https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/archive/0.20/power-profiles-daemon-0.20.tar
# sha256-8wSRPR/1ELcsZ9K3LvSNlPcJvxRhb/LRjTIxKtdQlCA=
```

## gpg-sshid-ctl.sh

This script manages what ssh keys are enabled or disabled when SSH for the user
is managed by the gpg-agent. For context, `ssh-add` can list or add these keys,
but the `-D` or `-d` options do not properly remove the keys from the
gpg-agent. This script provides a way to enable or disable these keys from the
sshcontrol for GPG so keys can be excluded for the user's various ssh interops
(e.g. git).

This script assumes `openssh` and `gnupg` are installed and available, and that
the gpg-agent is active and used as the ssh-agent for the user (see
`$SSH_AUTH_SOCK`).

This script only works for SSH key files that have already been added to the
gpg-agent via `ssh-add`, thereby the key file is tracked in the sshcontrol file
(by default at `~/.gnupg/sshcontrol`). This file can be edited by hand
following the comments for instructions.

This script is included via the [`home/gpg-agent.nix`](../home/gpg-agent.nix)
module.

### Examples

```bash
# Add a ssh key file to the gpg-agent
ssh-add ~/.ssh/id_ed25519

# List any ssh keys
ssh-add -l

# Disable all key files
gpg-sshid-ctl disable

# Enable all key files
gpg-sshid-ctl enable

# Disable single key file
gpg-sshid-ctl disable ~/.ssh/id_ed25519

# Enable single key file
gpg-sshid-ctl enable ~/.ssh/id_ed25519
```

## profiles-rebuild.sh

This script jointly upgrades both the NixOS and home-manager profiles. This
bypasses using `nixos-rebuild` that does not follow nix options used by the
newer nix-commands feature.

Any options desired to be passed to `nix build` can be passed to the script
directly.

This script is included via the [`os/upgrades.nix`](../os/upgrades.nix) module.

### Examples

```bash
profiles-rebuild

# Pass a remote builder to nix build
profiles-rebuild --builders ssh://remote-host
```

## root-diff.sh

This script temporarily mounts the entire btrfs volume for the system and
checks what files are on the root subvolume that are not linked from one of
the other subvolumes. This is to verify there are no state or configuration
files that should be persisted between boots, that would need to be included
in `persist.nix`. This is also useful for testing whether files remain between
boots that would be expected to be cleared by the `root-reset.sh` script.

This script is included via the [`os/persist.nix`](../os/persist.nix) module.

### Examples

```bash
sudo root-diff
```

## root-reset.sh

This script deletes any subvolumes from the root subvolume of the btrfs volume
and uses a `root-blank` snapshot to reset the subvolume. This script is not
designed to be run by the user, and is instead used by a rollback service in
the `persist.nix` module to run at stage-0 for systemd-boot and clear any
persistent files that are not in an intended persistent subvolume.

Assuming the rollback service is set up, this can be tested by creating a test
file:

```bash
echo "Test file" | sudo tee -a /etc/this-is-a-persistent-file

sudo root-diff | grep '/etc/this-is-a-persistent-file'
```

Then reboot, and after logging in check if the file is still there:

```bash
sudo root-diff | grep '/etc/this-is-a-persistent-file'
```

## test-build.sh

This script builds a system or user (home-manager) flake. This is to assist
in testing any profile in a current or remote flake in case of any input or
build errors. This is essentially an alias or shortcut so the full `nix build`
command does not need to be recalled.

Any options desired to be passed to `nix build` can be passed to the script
directly.

This script is included via the [`os/upgrades.nix`](../os/upgrades.nix) module.

### Examples

```bash
test-build user kjhoerr

# Pass a remote builder to nix build
test-build system whisker --builders ssh://remote-host
```


