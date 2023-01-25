# nonfree.nix
{
  nixpkgs.config.allowUnfree = true;
  # Workaround for https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = (_: true);
}

