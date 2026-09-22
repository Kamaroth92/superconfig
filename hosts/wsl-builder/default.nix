{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    #./hardware-configuration.nix
  ];

  networking.hostName = "wsl-builder";

  wsl.enable = true;
  wsl.defaultUser = "taneb";

  # stateVersion is already in common.nix, so drop it here
}
