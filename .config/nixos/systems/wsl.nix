# wsl.nix
{ lib, pkgs, ... }: {

  networking.hostName = "nixos-wsl";

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
        --prefix PATH ':' ${lib.makeBinPath ([ systemd gnugrep coreutils gnutar gzip git ])}
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

  # Provide wsl-vpnkit as built-in systemd service
  systemd.services.wsl-vpnkit = {
    enable = false;
    description = "Provide network connectivity to WSL2 when blocked by VPN";

    # Assumes wsl-vpnkit is installed as separate distro in WSL2.
    #
    # See: https://github.com/sakai135/wsl-vpnkit#setup-as-a-distro
    #
    # Could also try to set up a derivation to add the script as standalone so that
    # there is no external dependency. Would have to be managed and updated manually
    serviceConfig = {
      ExecStart = "/mnt/c/Windows/system32/wsl.exe -d wsl-vpnkit --cd /app wsl-vpnkit";
      Restart = "always";
      KillMode = "mixed";
    };

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.05";
}
