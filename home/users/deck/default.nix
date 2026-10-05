# Standalone home-manager profile, built via mkHome in flake.nix.
{ config, lib, ... }:

let
  localNix = ./local.nix;
  profiles = ../../profiles;
in

{
  imports = [
    "${profiles}/common.nix"
    "${profiles}/git.nix"
    "${profiles}/rbw.nix"
    "${profiles}/sops-common.nix"
    "${profiles}/zsh-oh-my-zsh.nix"
  ]
  ++ lib.optional (builtins.pathExists localNix) localNix;

  home.stateVersion = "26.05";

  home.file."repos/.keep".text = "";
}