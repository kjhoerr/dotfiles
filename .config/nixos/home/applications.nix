# applications.nix
{ lib, pkgs, ... }: {

  # Use lib.mkDefault where possible so user config can override without lib.mkForce

  # Install packages via programs.* where possible
  # May include extra config OOTB that the package does not
  programs.firefox.enable = lib.mkDefault true;
  programs.vscode.enable = lib.mkDefault true;
  programs.chromium = {
    enable = lib.mkDefault true;
    package = pkgs.ungoogled-chromium;
    dictionaries = [
      pkgs.hunspellDictsChromium.en_US
    ];
    extensions = [
      { id = "ocaahdebbfolfmndjeplogmgcagdmblk"; }
      { id = "nngceckbapebfimnlniiiahkandclblb"; }
      { id = "ecjfaoeopefafjpdgnfcjnhinpbldjij"; }
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; }
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; }
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "chromium-browser.desktop";
      "x-scheme-handler/http" = "chromium-browser.desktop";
      "x-scheme-handler/https" = "chromium-browser.desktop";
      "x-scheme-handler/about" = "chromium-browser.desktop";
      "x-scheme-handler/unknown" = "chromium-browser.desktop";
      "application/pdf" = "org.gnome.Evince.desktop";
    };
  };

  home.packages = lib.mkBefore (with pkgs; [
    blackbox-terminal
    foliate
    gnumeric
    jetbrains.datagrip
    keepassxc
    #kiwix
    obsidian
    switcheroo
  ]);

}

