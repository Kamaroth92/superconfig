# wsl-builder — NixOS-WSL builder running inside casper.
{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    (lib.custom.relativeToRoot "hosts/common/core")
    ./host-spec.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "taneb";
}
