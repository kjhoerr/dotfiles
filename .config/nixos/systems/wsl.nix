# wsl.nix
{ lib, pkgs, ... }: {

  networking.hostname = "nixos-wsl";

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    nativeSystemd = true;

    # Enable native Docker support
    docker-native.enable = true;

    # Needed to enable WSL wrapper for running VSCode WSL
    binShPkg = lib.mkForce (with pkgs; runCommand "nixos-wsl-bash-wrapper"
      {
        nativeBuildInputs = [ makeWrapper ];
      } ''
      makeWrapper ${bashInteractive}/bin/sh $out/bin/sh \
        --prefix PATH ':' ${lib.makeBinPath ([ systemd gnugrep coreutils gnutar gzip ])}
    '');
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    neovim
    kakoune
    git
    gnupg
    wget
  ];

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.05";
}
