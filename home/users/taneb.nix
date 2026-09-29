# Delivered as a NixOS module via users/taneb/default.nix.
{ ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/zsh-oh-my-zsh.nix
    ../profiles/git.nix
    ../profiles/rbw.nix
    ../profiles/kube.nix
    ../profiles/secrets.nix
    ../profiles/claude-code.nix
  ];

  home.stateVersion = "26.05";

  home.file."repos/.keep".text = "";
}
