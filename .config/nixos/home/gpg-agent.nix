# gpg-agent.nix
{ lib, ... }: {

  services.gnome-keyring.enable = lib.mkDefault false;
  services.gpg-agent.enable = lib.mkDefault true;
  services.gpg-agent.enableSshSupport = lib.mkDefault true;
  services.gpg-agent.enableExtraSocket = lib.mkDefault true;
  services.gpg-agent.pinentryFlavor = lib.mkDefault "gnome3";

}

