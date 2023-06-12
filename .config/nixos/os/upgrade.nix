# upgrade.nix
{ lib, ... }: {

  # Enable automatic upgrades through this flake repository
  system.autoUpgrade.enable = lib.mkDefault true;
  system.autoUpgrade.flake = lib.mkDefault "github:kjhoerr/dotfiles";

  # Since automatic updates are enabled, automatically gc older generations
  # To note, this will gc home-manager user profiles as well
  nix.gc.automatic = lib.mkDefault true;
  nix.gc.options = lib.mkDefault "--delete-older-than 14d";

  # Disable network targets due to common upgrade issues
  systemd = {
    targets.network-online.wantedBy = lib.mkForce []; # Normally ["multi-user.target"]
    services.NetworkManager-wait-online.wantedBy = lib.mkForce []; # Normally ["network-online.target"]
  };
}
