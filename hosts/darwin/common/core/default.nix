# Entry point shared by every nix-darwin host.
{
  inputs,
  lib,
  secrets,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    (lib.custom.relativeToRoot "modules/host-spec.nix")
    (lib.custom.relativeToRoot "hosts/darwin/common/users")
    ./darwin.nix
  ];

  # Soft secrets flow into hostSpec (networking only; unused by darwin today).
  hostSpec = {
    inherit (secrets) networking;
  };
}
