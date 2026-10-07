# Central user wiring: turns hostSpec.users into system users and home-manager
# users. Per-user system bits live in hosts/common/users/<user>/nixos.nix; the
# per-host home entry point is home/<user>/<hostName>.nix.
{
  inputs,
  config,
  pkgs,
  lib,
  secrets,
  ...
}:
let
  inherit (config) hostSpec;
in
{
  # System-wide tooling for root regardless of home-manager.
  programs.zsh.enable = true;
  programs.git.enable = true;

  users.users = lib.genAttrs hostSpec.users (
    user:
    {
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
    }
    // (import (lib.custom.relativeToRoot "hosts/common/users/${user}/nixos.nix") {
      inherit config lib;
    })
  );

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
    extraSpecialArgs = {
      inherit inputs secrets;
    };
    users = lib.genAttrs hostSpec.users (user: {
      imports = [ (lib.custom.relativeToRoot "home/${user}/${hostSpec.hostName}.nix") ];
    });
  };
}
