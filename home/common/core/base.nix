# Base tooling and session variables shared by every user.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    gnumake
    nh
    nixfmt
    sops
    vim
    wget
    kitty.terminfo # xterm-kitty terminfo for SSH from kitty
  ];

  # mkDefault so a per-user/host module can override without a merge conflict.
  home.sessionVariables =
    let
      flake = "${config.home.homeDirectory}/config";
    in
    {
      NH_FLAKE = lib.mkDefault flake;
      NH_HOME_FLAKE = lib.mkDefault flake;
      NH_OS_FLAKE = lib.mkDefault flake;
    };
}
