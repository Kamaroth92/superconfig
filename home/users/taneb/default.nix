# Standalone home-manager profile, built via mkHome in flake.nix.
{ lib, ... }:

let
  localNix = ./local.nix;
  profiles = ../../profiles;
in

{
  imports = [
    ./secrets.nix
    "${profiles}/base.nix"
    "${profiles}/zsh-oh-my-zsh.nix"
    "${profiles}/rbw.nix"
    "${profiles}/git.nix"
    "${profiles}/ssh.nix"
    "${profiles}/kube.nix"
    "${profiles}/claude-code.nix"
  ]
  ++ lib.optional (builtins.pathExists localNix) localNix;

  home.stateVersion = "26.05";

  home.file."repos/.keep".text = "";
}
