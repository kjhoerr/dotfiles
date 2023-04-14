# secure-boot.nix
# Requires lanzaboote flake
{ lib, pkgs, ... }: {

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_hardened;
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  boot.supportedFilesystems = [ "btrfs" ];

  # Quiet boot with plymouth - supports LUKS passphrase entry if needed
  boot.kernelParams = [
    "quiet"
    "loglevel=0"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    # The following parameters are all hardening measures
    "slab_nomerge"
    "vsyscall=none"
    "debugfs=off"
    "oops=panic"
    "module.sig_enforce=1"
    "lockdown=confidentiality"
    "mce=0"
    "spectre_v2=on"
    "spec_store_bypass_disable=on"
    "tsx=off"
    "tsx_async_abort=full,nosmt"
    "mds=full,nosmt"
    "l1tf=full,force"
    "nosmt=force"
    "kvm.nx_huge_pages=force"
  ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.plymouth.enable = true;
  security.lockKernelModules = true;
  security.allowUserNamespaces = true;

  # Disable mostly inert net protocols and drivers
  boot.blacklistedKernelModules = [
    "dccp"
    "sctp"
    "rds"
    "tipc"
    "n-hdlc"
    "x25"
    "decnet"
    "econet"
    "af_802154"
    "ipx"
    "appletalk"
    "psnap"
    "p8023"
    "p8022"
    "can"
    "atm"
    "jffs2"
    "hfsplus"
    "squashfs"
    "udf"
    "cifs"
    "gfs2"
    "vivid"
  ];

  # Additional hardening by kernel configuration
  boot.kernel.sysctl = {
    "kernel.printk" = "3 3 3 3";
    "dev.tty.ldisc_autoload" = "0";
    "kernel.sysrq" = "4";
    "net.ipv4.tcp_rfc1337" = "1";
    "net.ipv6.conf.all.accept_ra" = "0";
    "net.ipv6.default.accept_ra" = "0";
    "net.ipv4.tcp_sack" = "0";
    "net.ipv4.tcp_dsack" = "0";
    "net.ipv4.tcp_timestamps" = "0";
    "kernel.yama.ptrace_scope" = "2";
    "fs.protected_fifos" = "2";
    "fs.protected_regular" = "2";
    "syskernel.core_pattern" = "|/bin/false";
    "fs.suid_dumpable" = "0";
  };

  # madman: switch sudo with doas
  security.doas.enable = lib.mkDefault true;
  security.sudo.enable = lib.mkDefault false;

  # Bootspec and Secure Boot using lanzaboote
  #
  # See: https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
  #
  boot.bootspec.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # TPM for unlocking LUKS
  #
  # TPM kernel module must be enabled for initrd. Device driver is viewable via the command:
  # sudo systemd-cryptenroll --tpm2-device=list
  # And added to a device's configuration:
  # boot.initrd.kernelModules = [ "tpm_tis" ];
  #
  # Must be enabled by hand - e.g.
  # sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p3 --tpm2-device=auto --tpm2-pcrs=0+2+7
  #
  security.tpm2.enable = true;
  security.tpm2.tctiEnvironment.enable = true;

}

