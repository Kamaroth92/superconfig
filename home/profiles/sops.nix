# Not for users whose ~/.gitconfig is managed outside Nix.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    sops
  ];
}
