# Standalone home-manager profile, built via mkHome in flake.nix.
{
  lib,
  profiles,
  ...
}:

let
  localNix = ./local.nix;
in

{
  imports =
    profiles [
      "common"
      "git"
      "rbw"
      "sops-common"
      "zsh-oh-my-zsh"
    ]
    ++ lib.optional (builtins.pathExists localNix) localNix;

  home.stateVersion = "26.05";

  home.file."repos/.keep".text = "";
}
