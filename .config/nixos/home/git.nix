# git.nix
{ lib, pkgs, ... }: {

  programs.git.enable = lib.mkDefault true;
  programs.git.package = lib.mkDefault pkgs.gitAndTools.gitFull;
  programs.git.userName = lib.mkDefault "Kevin J Hoerr";
  programs.git.userEmail = lib.mkDefault "kjhoerr@protonmail.com";
  programs.git.signing.key = lib.mkDefault "BEDBA29269ED7111";
  programs.git.signing.signByDefault = lib.mkDefault true;
  programs.git.extraConfig.init.defaultBranch = "trunk";
  programs.git.extraConfig.core.editor = "nvim";
  programs.git.extraConfig.color.ui = "always";
  programs.git.extraConfig.stash.showPatch = true;
  programs.git.extraConfig.pull.ff = "only";
  programs.git.extraConfig.push.autoSetupRemote = true;

}

