{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    #./hardware-configuration.nix
  ];

  networking.hostName = "wsl-builder";

  # WSL has no real hardware to scan, so declare the platform directly
  nixpkgs.hostPlatform = "x86_64-linux";

  wsl.enable = true;
  wsl.defaultUser = "taneb";

  # stateVersion is already in common.nix, so drop it here
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
}
