# kjhoerr dotfiles

## NixOS Configuration

All of my systems and user profiles are defined under a common [flake.nix](./flake.nix). This allows me to update my systems targetting this flake:

```bash
# Invoked off of current hostname
sudo nixos-rebuild --flake github:kjhoerr/dotfiles switch
```

And I can update my user's home configurations against this flake as well:

```bash
# home-manager isn't installed via OS config, and is on the user profile - if needed, install:
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
# For complicated reasons, may need to re-login here for the next command to work
nix-shell '<home-manager>' -A install

# Invoked off of current username
home-manager --flake github:kjhoerr/dotfiles switch
```

In this way system and user profiles can be managed and updated separately. Configuration changes can be made without needing to interact with each system, and configuration can be simplified through sharing common outputs.

Auto-upgrade and garbage collection is enabled using the default daily frequency and targets `github:kjhoerr/dotfiles` as above. (This option does not exist yet for home-manager flake configurations, unfortunately.)

The flake itself is kept as simple as possible: only necessary inputs, and no overlays. All imports are referenced directly through the flake rather than using nested imports to make it clear which configurations are being actively used by each system and user.

### Instructions for adding a new NixOS system

Note: These are incomplete and a rough first draft, and mostly are to catalog the steps to help me remember if/when I do this in the future. My config is pretty geared toward myself obviously, so these installation steps nor the configs may match what you want to do, but I have also tried to make my config and installation instructions as accessible as I can if it helps anyone else.

Generally, the install process goes something like this:

1. Boot from NixOS install media. I always use the GNOME iso just in case I want to play around with something, but the minimal iso should be more than feasible.

https://nixos.org/download.html#nixos-iso

2. Set up partitions. The common system configuration in this repository is centered around using LUKS and BTRFS subvolumes and snapshots. LVM can be utilized as well. Per system subvoluming can be fairly flexible, as long as the root can be cleared at each boot, or system Nix files like `persist.nix` can't be used.

Here is an example. All commands should be run from root:

```bash
# Set up partitions as desired. At least one fat32 for /boot or /boot/efi is needed along a main LUKS partition.
parted /dev/nvme0n1

# /boot
mkfs.vfat -F32 /dev/nvme0n1p1

# LUKS partition
cryptsetup --verify-passphrase -v luksFormat /dev/nvme0n1p2
# >>> YES; create passphrase for LUKS partition
cryptsetup open /dev/nvme0n1p2 enc
# re-enter passphrase to open LUKS partition for more partition management

# Optionally, if you want to use LVM and set up additional partitions like swap, you can do the following, otherwise skip this block
# Initialize volumegroup `pool`
vgcreate pool /dev/mapper/enc
# Create individual logical volumes
lvcreate -n swap --size 16G pool
mkswap /dev/pool/swap
lvcreate -n root --extents 100%FREE pool
mkfs.btrfs /dev/pool/root

# If not using LVM, run this instead:
mkfs.btrfs /dev/mapper/enc
# From now on I'll be referring to the root partition as `/dev/pool/root`. If not using LVM substitute `/dev/mapper/enc` where applicable

# Mount btrfs root partition to initialize subvolumes
mount -t btrfs /dev/pool/root /mnt

# Create subvolumes under btrfs root partition
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log

# Take an empty readonly snapshot of the btrfs root
btrfs subvolume snapshot -r /mnt/root /mnt/root-blank
umount /mnt

# aliasing function to simplify typing if need be:
# function pm { mount -o subvol=$1,compress=zstd,noatime /dev/pool/root /mnt/$2 ; }
# `pm root`
# `pm home home`
# `pm log var/log`

mount -o subvol=root,compress=zstd,noatime    /dev/pool/root /mnt/

mkdir /mnt/{boot,home,nix,persist,var/log}
mount -o subvol=home,compress=zstd,noatime    /dev/pool/root /mnt/home
mount -o subvol=nix,compress=zstd,noatime     /dev/pool/root /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/pool/root /mnt/persist
mount -o subvol=log,compress=zstd,noatime     /dev/pool/root /mnt/var/log
mount /dev/nvme0n1p1 /mnt/boot

# Now all partitions should be mounted on /mnt as the chroot for the installed system
```

3. Generate configuration based on the hardware and pull the bootstrap config from this repository

```bash
nixos-generate-config --root /mnt

# By default the generated configuration.nix is practically empty so we can overwrite it - feel free to review it first or move it
curl -sSL https://raw.githubusercontent.com/kjhoerr/dotfiles/trunk/.config/nixos/systems/bootstrap.nix -o /mnt/etc/nixos/configuration.nix
# Edit the bootstrap configuration if need be - should include everything out of the box to switch to use sbctl, systemd-cryptsetup and whatever else to move to using the system flake. The hostname should be changed to "pick" the correct flake but that can be done later
```

4. Edit the `hardware-configuration.nix`. There are typically a couple of things missing that you will need to add:

    - `"compress=zstd" "noatime"` on each of the btrfs subvolumes
    - `neededForBoot = true;` for persist and log subvolumes
    - If using LVM, the LUKS spec is missing entirely. This should be:

      ```nix
        boot.initrd.luks.devices."enc" = {
          device = "/dev/disk/by-uuid/..." # UUID can be found using: `blkid | grep /dev/nvme0n1p2`
          preLVM = true; # only needed if using LVM
        }
      ```

5. Once edits are complete all that should be left to do is:

```bash
nixos-install
```

And reboot! We're only halfway there, but we're at the fun part! Next is all about managing secureboot, TPM, and getting the impermanence set up.

6. Post-bootstrap instructions (TODO: expand these into separate steps): use sbctl to create, enroll keys (have to enter setup mode, which depends on the device) for secure boot. Enable TPM unlocking using systemd-cryptenroll. Copy files and directories to /persist. Create persisted passwords. Create or modify system configuration flake. Reboot.

TODO: Fallback instructions - reboot installation media, remount partitions and nixos-enter

Huge s/o to https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html

## Guix System Configuration

These configurations aren't actively being used but were at one point a working system.

