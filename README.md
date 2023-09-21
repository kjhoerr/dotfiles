# kjhoerr dotfiles
[![update](https://github.com/kjhoerr/dotfiles/actions/workflows/update.yml/badge.svg)](https://github.com/kjhoerr/dotfiles/actions/workflows/update.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## NixOS Configuration

All of my systems and user profiles are defined under a common [flake.nix](./flake.nix). This allows me to update my systems targetting this flake:

```bash
# Invoked off of current hostname
sudo nixos-rebuild --flake github:kjhoerr/dotfiles switch
```

And I can update my user's home configurations against this flake as well:

```bash
# Invoked off of current username
home-manager --flake github:kjhoerr/dotfiles switch
```

In this way system and user profiles can be managed and updated separately. Configuration changes can be made without needing to interact with each system, and configuration can be simplified through sharing common outputs.

Auto-upgrade and garbage collection is enabled using the default daily frequency and targets `github:kjhoerr/dotfiles` as above. (This option does not exist yet for home-manager flake configurations, unfortunately.)

The flake itself is kept as simple as possible: necessary inputs only and target stable branches where possible. All imports are referenced directly through the flake rather than using nested imports to make it clear which configurations are being actively used by each system and user.

### Instructions for adding a new NixOS system

See this [wiki page](https://github.com/kjhoerr/dotfiles/wiki/NixOS:-Instructions-for-adding-a-new-system) for more information on installing NixOS based on this repository's flake.

## Guix System Configuration

These configurations aren't actively being used but were at one point a working system.

## License

This project is licensed under [the MIT License](./LICENSE).

