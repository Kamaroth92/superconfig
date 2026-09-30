# Standalone home-manager, for hosts where Nix is installed but NixOS is not.
{
  inputs,
  system,
}:

{
  username,
  # Optional: hosts that need no host-specific behaviour (the generic
  # "<user>" key, plain Nix-on-Ubuntu servers) can leave this unset.
  hostname ? null,
  modules,
}:

let
  # Shared modules must not set nixpkgs.config -- it is a no-op under the NixOS
  # path's useGlobalPkgs.
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  extraSpecialArgs = {
    inherit inputs hostname;
    standalone = true;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };

  modules = modules ++ [
    inputs.sops-nix.homeManagerModules.sops
    (
      { pkgs, ... }:
      {
        home.username = username;
        home.homeDirectory = "/home/${username}";

        targets.genericLinux.enable = true;
        # Defaults on with genericLinux; nags about GPU drivers on every switch.
        targets.genericLinux.gpu.enable = false;

        # Otherwise LOCALE_ARCHIVE_2_27 drags in the full ~200MB archive.
        i18n.glibcLocales = pkgs.glibcLocales.override {
          allLocales = false;
          locales = [ "en_AU.UTF-8/UTF-8" ];
        };
      }
    )
  ];
}
