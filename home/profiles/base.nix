# Shared by every user. No NixOS options, no nixpkgs.config.
{
  config,
  lib,
  pkgs,
  inputs,
  standalone,
  ...
}:

{
  home.packages =
    (with pkgs; [
      gnumake
      nh
      nixfmt
      vim
      wget
    ])
    # Redundant on NixOS, where the module drives activation.
    ++ lib.optional standalone inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default;

  home.sessionVariables = {
    NH_FLAKE = "${config.home.homeDirectory}/config";
  };
}
