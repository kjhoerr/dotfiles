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
nix-shell '<home-manager>' -A install

# Invoked off of current username
home-manager --flake github:kjhoerr/dotfiles switch
```

In this way system and user profiles can be managed and updated separately. Configuration changes can be made without needing to interact with each system, and configuration can be simplified through sharing common outputs.

The flake itself is kept as simple as possible: only necessary inputs, and no overlays. All imports are referenced directly through the flake rather than using nested imports to make it clear which configurations are being actively used by each system and user.

## Guix System Configuration

These configurations aren't actively being used but were at one point a working system.

