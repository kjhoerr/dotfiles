# wsl.nix
{ lib, pkgs, ... }: {

  networking.hostName = "nixos-wsl";

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    usbip.enable = true;

    extraBin = [
      { src = "${lib.getExe pkgs.bash}"; }
      { src = "${lib.getExe' pkgs.linuxPackages.usbip "usbip"}"; }
    ];

    # Needed to enable WSL wrapper for running VSCode WSL
    binShPkg = lib.mkForce (with pkgs; runCommand "nixos-wsl-bash-wrapper"
      {
        nativeBuildInputs = [ makeWrapper ];
      } ''
      makeWrapper ${bashInteractive}/bin/sh $out/bin/sh \
        --prefix PATH ':' ${lib.makeBinPath ([ systemd gnugrep coreutils gnutar gzip git ])}
    '');
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  hardware.graphics.enable = lib.mkForce false;

  programs.zsh.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    neovim
    kakoune
    kmod
    usbutils
    git
    gnupg
    wget
  ];

  services.pcscd.enable = true;

  virtualisation.docker.enable = true;

  # Allow foreign binaries to run on NixOS
  programs.nix-ld.enable = true;

  # Provide wsl-vpnkit as built-in systemd service
  systemd.services.wsl-vpnkit = {
    # This service will not run by default
    # To run at boot change wantedBy to [ "multi-user.target" ]
    enable = true;
    description = "Provide network connectivity to WSL2 when blocked by VPN";

    serviceConfig = {
      Type = "idle";
      ExecStart = "${pkgs.wsl-vpnkit}/bin/wsl-vpnkit";
      Restart = "always";
      KillMode = "mixed";
    };

    after = [ "network.target" ];
    wantedBy = lib.mkDefault [ ];
  };

  # Enable nix flakes
  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = "22.05";
}
