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

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      deploy-rs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      mkHome = import ./lib/mkHome.nix { inherit inputs system; };

      testing = import ./lib/testing.nix {
        pkgs = nixpkgs.legacyPackages.${system};
        inherit self;
      };
    in
    {
      # Exposed so a downstream private user flake (e.g. ffma-nix) can build a
      # home configuration against these shared profiles without this repo
      # needing to know it exists.
      lib = {
        inherit mkHome;
        profiles = import ./lib/profiles.nix { };
      };

      # System only -- home-manager is delivered standalone on every host, so a
      # dotfile change never requires a system rebuild. See homeConfigurations.
      nixosConfigurations = {
        melchior = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./nixos/modules/common.nix
            ./nixos/machines/melchior
          ];
        };

        wsl-builder = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          modules = [
            ./nixos/modules/common.nix
            ./nixos/machines/wsl-builder
          ];
        };
      };

      # Keyed "<user>@<hostname>", which is what `nh home switch` looks for. It
      # falls back to the bare "<user>" key, so the generic entry is what any
      # Nix-on-Ubuntu host picks up without needing an entry of its own.
      homeConfigurations =
        let
          taneb = mkHome {
            username = "taneb";
            modules = [ ./home/users/taneb ];
          };

          deck = mkHome {
            username = "deck";
            hostname = "steamdeck";
            modules = [ ./home/users/deck ];
          };

          administrator =
            host:
            mkHome {
              username = "administrator";
              hostname = host;
              modules = [ ./home/users/administrator ];
            };

          ergo =
            host:
            mkHome {
              username = "ergo";
              hostname = host;
              modules = [ ./home/users/ergo ];
            };
        in
        {
          inherit taneb deck;
          "taneb@melchior" = taneb;
          "taneb@wsl-builder" = taneb;
          "deck@steamdeck" = deck;

          administrator = administrator "ergo-dns-01"; # bare fallback key
          "administrator@ergo-dns-01" = administrator "ergo-dns-01";
          "administrator@ergo-node-01" = administrator "ergo-node-01";
          "administrator@ergo-node-02" = administrator "ergo-node-02";
          "administrator@ergo-node-03" = administrator "ergo-node-03";

          "ergo@ergo-node-01" = ergo "ergo-node-01"; # future state
          "ergo@ergo-node-02" = ergo "ergo-node-02";
          "ergo@ergo-node-03" = ergo "ergo-node-03";
        };

      # Remote deploys via deploy-rs. Each `hostname` refers to a `deploy-*`
      # alias in home/profiles/ssh.nix, which carries the deploy key and the
      # target user/port.
      deploy = {
        nodes = {
          melchior = {
            hostname = "deploy-melchior";
            sshUser = "root";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.melchior;
            };
          };

          wsl-builder = {
            hostname = "deploy-wsl-builder";
            sshUser = "root";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.wsl-builder;
            };
          };

          ergo-dns-01 = {
            hostname = "deploy-ergo-dns-01";
            sshUser = "administrator";
            profiles.home = {
              user = "administrator";
              path =
                deploy-rs.lib.${system}.activate.home-manager
                  self.homeConfigurations."administrator@ergo-dns-01";
            };
          };
        };
      };

      apps.${system} = testing.apps;

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
