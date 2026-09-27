{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # colmena.url = "github:zhaofengli/colmena";

  };

  outputs =
    {
      self,
      nixpkgs,
      # colmena,
      ...
    }@inputs:
    {
      nixosConfigurations = {

        melchior = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            machineSecretsPath = ./secrets/melchior.yaml;
          };

          modules = [
            ./modules/common.nix
            ./machines/melchior
          ];
        };

        wsl-builder = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            machineSecretsPath = ./secrets/wsl-builder.yaml;
          };

          modules = [
            ./modules/common.nix
            ./machines/wsl-builder
          ];
        };

      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      # colmenaHive = colmena.lib.makeHive self.outputs.colmena;

      # colmena = {
      #   meta = {
      #     nixpkgs = import nixpkgs {
      #       system = "x86_64-linux";
      #     };
      #     specialArgs = { inherit inputs; };
      #     nodeSpecialArgs = {
      #       melchior.machineSecretsPath = ./secrets/melchior.yaml;
      #       wsl-builder.machineSecretsPath = ./secrets/wsl-builder.yaml;
      #     };
      #   };

      #   melchior = {
      #     deployment = {
      #       targetHost = "melchior";
      #       targetPort = 2222;
      #       targetUser = "taneb";
      #     };
      #     imports = [
      #       ./modules/common.nix
      #       ./machines/melchior
      #     ];
      #   };

      #   wsl-builder = {
      #     deployment = {
      #       targetHost = "wsl-builder";
      #       targetPort = 2222;
      #       targetUser = "taneb";
      #     };
      #     imports = [
      #       ./modules/common.nix
      #       ./machines/wsl-builder
      #     ];
      #   };
      # };
    };
}
