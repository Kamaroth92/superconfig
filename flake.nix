{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ffma-nix = {
      url = "git+file:///home/ffma/ffma-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.sops-nix.follows = "sops-nix";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      mkHome = import ./lib/mkHome.nix { inherit inputs system; };
    in
    {
      nixosConfigurations = {
        melchior = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./modules/common.nix
            ./machines/melchior
          ];
        };

        wsl-builder = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./modules/common.nix
            ./machines/wsl-builder
          ];
        };
      };

      # Keyed "<user>@<hostname>", which is what `nh home switch` looks for.
      homeConfigurations =
        let
          ffma-wsl = mkHome {
            username = "ffma";
            hostname = "FF-5CG30956H8";
            modules = [ ./home/users/ffma ];
          };
        in
        {
          "ffma@FF-5CG30956H8" = ffma-wsl;
          ffma = ffma-wsl;
        };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
