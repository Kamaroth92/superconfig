{
  inputs,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.useGlobalPkgs = true; # reuse NixOS pkgs (allowUnfree)
  home-manager.backupFileExtension = "backup";
  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  # Mirrors lib/mkHome.nix.
  home-manager.extraSpecialArgs = {
    inherit inputs;
    standalone = false;
  };
}
