# Delivers home-manager as part of the NixOS system closure so `nh os switch`
# applies dotfiles too. Also available standalone via `nh home switch` — see
# homeConfigurations in flake.nix.
{
  inputs,
  pkgs,
  config,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";

  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home-manager.extraSpecialArgs = {
    inherit inputs;
    standalone = false;
    hostname = config.networking.hostName;
    profiles = import ../../lib/profiles.nix { };
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit (pkgs.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
