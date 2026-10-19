# Kubernetes tooling.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kubectl
    kubectx
    kubernetes-helm
    k9s
    stern
    kustomize
  ];
}
