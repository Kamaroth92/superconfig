# Future state: the homelab user for ergo-node-*. Deployed once those hosts
# migrate from the transitional `administrator` account. Deliberately no
# git.nix (it hardcodes Tane's identity) and no workstation tooling.
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
    profiles [ "common" "kube" "sops-common" "ssh" "zsh-oh-my-zsh" "ergo-homelab" ]
    ++ lib.optional (builtins.pathExists localNix) localNix;

  home.stateVersion = "26.05";
}