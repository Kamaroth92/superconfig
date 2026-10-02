# Standalone home-manager profile, built via mkHome in flake.nix.
{ config, lib, ... }:

let
  localNix = ./local.nix;
  profiles = ../../profiles;
in

{
  imports = [
    ./secrets.nix
    "${profiles}/claude-code-common.nix"
    "${profiles}/claude-code-openrouter.nix"
    "${profiles}/common.nix"
    "${profiles}/git.nix"
    "${profiles}/kube.nix"
    "${profiles}/rbw.nix"
    "${profiles}/sops-common.nix"
    "${profiles}/ssh.nix"
    "${profiles}/terraform.nix"
    "${profiles}/zsh-oh-my-zsh.nix"
  ]
  ++ lib.optional (builtins.pathExists localNix) localNix;

  home.stateVersion = "26.05";

  home.file."repos/.keep".text = "";
}
