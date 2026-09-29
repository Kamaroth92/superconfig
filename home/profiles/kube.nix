# KUBECONFIG lives in secrets.nix, so this profile stays portable.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
    kubectx
    kubernetes-helm
    k9s
  ];
}
