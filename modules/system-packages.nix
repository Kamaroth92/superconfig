{
  pkgs,
  ...
}:

{
  # ── Shared packages ─────────────────────────────────────
  environment.systemPackages = with pkgs; [
    colmena
    gnumake
    sops
    bws
    vim
    git
    wget
    nixfmt
    nh
    kubectl
    kubectx 
    kubernetes-helm
  ];
}
