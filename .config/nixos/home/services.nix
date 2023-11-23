# services.nix
{ lib, pkgs, ... }: {

  # For WSL, need to use VSCode WSL extension version 0.76.0 and set
  #   "remote.WSL2.connectionMethod": "wsl2VMAddress",
  # See: https://github.com/microsoft/vscode-remote-release/issues/8305
  # And: https://github.com/nix-community/NixOS-WSL/issues/231
  services.vscode-server.enable = lib.mkDefault true;

  services.vscode-server.nodejsPackage = pkgs.nodejs-18_x;
  services.vscode-server.extraRuntimeDependencies = lib.mkDefault [ pkgs.curl ];
  services.vscode-server.enableFHS = lib.mkDefault true;
}
