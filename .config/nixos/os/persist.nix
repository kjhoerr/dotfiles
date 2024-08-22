# persist.nix
# Requires impermanence flake
{ lib, pkgs, ... }:
let
  root-reset-src = builtins.readFile ../scripts/root-reset.sh;
  root-diff = pkgs.writeShellApplication {
    name = "root-diff";
    runtimeInputs = [ pkgs.btrfs-progs ];
    text = builtins.readFile ../scripts/root-diff.sh;
  };
in {

  boot.initrd.systemd.enable = lib.mkDefault true;
  boot.initrd.systemd.services.rollback = {
    description = "Rollback BTRFS root subvolume to a pristine state";
    wantedBy = [
      "initrd.target"
    ];
    after = [
      # LUKS/TPM process
      "systemd-cryptsetup@enc.service"
    ];
    before = [
      "sysroot.mount"
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = root-reset-src;
  };
  boot.initrd.systemd.services.persisted-files = {
    description = "Hard-link persisted files from /persist";
    wantedBy = [
      "initrd.target"
    ];
    after = [
      "sysroot.mount"
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /sysroot/etc/
      ln -snfT /persist/etc/machine-id /sysroot/etc/machine-id
    '';
  };

  # symlinks to enable "erase your darlings"
  environment.persistence."/persist" = {
    directories = [
      "/etc/secureboot"
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/colord"
      "/var/lib/docker"
      "/var/lib/fprint"
      "/var/lib/AccountsService"
      "/var/lib/nixos"
      "/var/lib/power-profiles-daemon"
      "/var/lib/tailscale"
      "/var/lib/upower"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/var/lib/NetworkManager/secret_key"
      "/var/lib/NetworkManager/seen-bssids"
      "/var/lib/NetworkManager/timestamps"
    ];
  };

  environment.systemPackages = lib.mkBefore [ root-diff ];

}
