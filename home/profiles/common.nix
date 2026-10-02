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
    # mkDefault so a downstream flake (e.g. ffma-nix) can point this at its own
    # checkout -- sessionVariables is an attrset, so a plain value on both sides
    # would be a merge conflict rather than an override.
    NH_FLAKE = lib.mkDefault "${config.home.homeDirectory}/config";
  };
}
