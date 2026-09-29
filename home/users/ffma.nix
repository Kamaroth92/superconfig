# Standalone home-manager on Ubuntu WSL2.
#   nh home switch
# Identity and genericLinux come from lib/mkHome.nix.
{ ... }:

{
  imports = [
    ../profiles/base.nix
    ../profiles/zsh-oh-my-zsh.nix
    ../profiles/kube.nix
  ];

  home.stateVersion = "26.05";
}
