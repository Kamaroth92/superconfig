# Home-manager wiring for the work Mac. Username (tane.barriball) differs from
# the person directory (home/taneb/), so this is explicit rather than the
# NixOS genAttrs (which assumes username == directory).
{
  inputs,
  config,
  pkgs,
  lib,
  secrets,
  ...
}:
let
  username = "tane.barriball";
in
{
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    extraSpecialArgs = {
      inherit inputs secrets;
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    };
    users.${username} = {
      imports = [
        (lib.custom.relativeToRoot "home/taneb/${config.hostSpec.hostName}.nix")
      ];
    };
  };
}
