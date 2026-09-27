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
  ];
}
