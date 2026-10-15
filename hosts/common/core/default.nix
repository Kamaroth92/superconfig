# Entry point shared by every NixOS host.
{
  inputs,
  config,
  lib,
  secrets,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    (lib.custom.relativeToRoot "modules/host-spec.nix")
    (lib.custom.relativeToRoot "hosts/common/users")
    ./nixos.nix
  ];

  networking.hostName = config.hostSpec.hostName;

  # Soft secrets (from nix-secrets) flow into hostSpec, so modules read e.g.
  # config.hostSpec.networking.hosts.<hostName>.ip.
  hostSpec = {
    inherit (secrets) networking;
  };
}
