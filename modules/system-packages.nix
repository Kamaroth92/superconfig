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
    pinentry-curses
    rbw
    bws
    vim
    git
    wget
    nixfmt
  ];
}
