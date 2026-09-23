{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    sops-nix.url = "github:Mic92/sops-nix";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena.url = "github:zhaofengli/colmena";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-index-database = {
    #   url = "github:nix-community/nix-index-database";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      colmena,
      ...
    }@inputs:
    {
      nixosConfigurations = {

        melchior = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/common.nix
            ./hosts/melchior
          ];
        };

        wsl-builder = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./modules/common.nix
            ./hosts/wsl-builder
          ];
        };

      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      colmenaHive = colmena.lib.makeHive self.outputs.colmena;

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          specialArgs = { inherit inputs; };
        };

        melchior = {
          deployment = {
            targetHost = "melchior";
            targetPort = 2222;
            targetUser = "taneb";
          };
          imports = [ ./modules/common.nix ];
        };

        wsl-builder = {
          deployment = {
            targetHost = "wsl-builder";
            targetPort = 2222;
            targetUser = "taneb";
          };
          imports = [ ./modules/common.nix ];
        };
      };
    };
}
