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
    [ ./secrets.nix ]
    ++ profiles [
      "claude-code-common"
      "claude-code-openrouter"
      "common"
      "git"
      "kube"
      "rbw"
      "sops-common"
      "ssh"
      "terraform"
      "zsh-oh-my-zsh"
    ]
    ++ lib.optional (builtins.pathExists localNix) localNix;

  home.stateVersion = "26.05";

  home.file."repos/.keep".text = "";
}