# Standalone home-manager profile, built via mkHome in flake.nix.
{
  lib,
  pkgs,
  inputs,
  profiles,
  ...
}:

let
  localNix = ./local.nix;
in

{
  imports = [
    ./secrets.nix
  ]
  ++ profiles [
    "claude-code-common"
    "claude-code-deepseek"
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

  # deploy-rs CLI for remote deploys (see the `deploy` output in flake.nix).
  home.packages = [
    inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.deploy-rs
  ];

  # Short aliases for the eval/build matrix (see lib/testing.nix).
  programs.zsh.shellAliases = {
    ne = "nix run ~/config#eval -- ";
    nb = "nix run ~/config#build -- ";
  };

  home.file."repos/.keep".text = "";
}
