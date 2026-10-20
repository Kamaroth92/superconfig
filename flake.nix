{
  description = "Tane's NixOS + home-manager config, structured after EmergentMind/nix-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
      # Edits are ignored until `nix flake lock --update-input nix-secrets`.
      # url = "git+ssh://git@github.com/Kamaroth92/nix-secrets.git";
      url = "path:/home/taneb/repos/nix-secrets";
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
      home-manager,
      nix-secrets,
      deploy-rs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Soft secrets from nix-secrets; hard secrets arrive via sops-nix.
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
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            (customLib.custom.relativeToRoot "home/${username}/${hostname}.nix")
            {
              # Foreign OS: target generic Linux, not NixOS.
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
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

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

      # deploy-rs: each hostname is a deploy-* ssh alias (deploy key + user/port).
      deploy = {
        nodes = {
          melchior = {
            groups = [ "taneb" ];
            hostname = "deploy-melchior";
            sshUser = "root";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.melchior;
            };
          };

          wsl-builder = {
            groups = [ "taneb" ];
            hostname = "deploy-wsl-builder";
            sshUser = "root";
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.wsl-builder;
            };
          };

          ergo-dns-01 = {
            groups = [ "administrator" ];
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
    };
}
