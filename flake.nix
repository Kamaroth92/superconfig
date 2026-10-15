{
  description = "Tane's NixOS + home-manager config, structured after EmergentMind/nix-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-secrets = {
      # Local override for testing. Point at a git remote once it's pushed:
      #   url = "git+ssh://git@github.com/tanebarriball/nix-secrets.git";
      url = "path:/home/taneb/repos/nix-secrets";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-secrets,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Soft secrets from the private nix-secrets repo. Hard secrets arrive at
      # runtime via sops-nix (see hosts/common/core).
      secrets = nix-secrets;

      customLib = nixpkgs.lib.extend (
        self: super: {
          custom = import ./lib { inherit (nixpkgs) lib; };
        }
      );

      # Full NixOS hosts live under hosts/nixos/<hostname>/default.nix.
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs secrets;
            lib = customLib;
          };
          modules = [ (customLib.custom.relativeToRoot "hosts/nixos/${hostname}") ];
        };

      # Standalone home-manager hosts (Nix on another OS) live under
      # home/<user>/<hostname>.nix.
      mkHome =
        {
          username,
          hostname,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            inherit inputs secrets;
          };
          modules = [
            (customLib.custom.relativeToRoot "home/${username}/${hostname}.nix")
            {
              # Home-manager on a foreign OS: target generic Linux, not a NixOS
              # or home-manager-managed system.
              targets.genericLinux.enable = true;
              home = {
                username = username;
                homeDirectory = "/home/${username}";
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        melchior = mkHost "melchior";
        wsl-builder = mkHost "wsl-builder";
      };

      homeConfigurations = {
        "deck@steamdeck" = mkHome {
          username = "deck";
          hostname = "steamdeck";
        };
        "administrator@ergo-dns-01" = mkHome {
          username = "administrator";
          hostname = "ergo-dns-01";
        };
        "administrator@ergo-node-04" = mkHome {
          username = "administrator";
          hostname = "ergo-node-04";
        };
        "ergo@ergo-node-04" = mkHome {
          username = "ergo";
          hostname = "ergo-node-04";
        };
      };
    };
}
