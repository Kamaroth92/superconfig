# Reusing the shared modules from an external flake

You don't have to be a user in this repo to reuse its `home/common` modules.
Add this repo as a flake input, import the module files you want, and pass the
special args they expect.

## Example flake

```nix
# external-user/flake.nix — reuse shared home modules from the superconfig repo.
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # This repo. Use a git URL, or `path:/path/to/checkout` for local.
    superconfig.url = "github:you/config";
  };

  outputs = { nixpkgs, home-manager, superconfig, ... }:
  let
    system = "x86_64-linux";
  in
  {
    homeConfigurations."external-user" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};

      # Special args the shared modules read.
      extraSpecialArgs = {
        # home/common/core builds ~/.config/hosts from secrets.networking.hosts
        # and ~/.ssh/authorized_keys from secrets.users.<name>.sshKeys.
        # Provide your own values; this stub is enough if you have neither.
        secrets = {
          networking.hosts = { };
        };

        # Needed only by home/common/optional/vault.nix.
        pkgs-unstable = import nixpkgs { inherit system; };
      };

      modules = [
        # Base shell + tooling (zsh, oh-my-zsh theme, git, kitty terminfo).
        "${superconfig}/home/common/core/default.nix"

        # Shared optional modules — import the ones you want.
        "${superconfig}/home/common/optional/kube.nix"
        # "${superconfig}/home/common/optional/aws.nix"
        # "${superconfig}/home/common/optional/terraform.nix"
        # "${superconfig}/home/common/optional/rbw.nix"
        # "${superconfig}/home/common/optional/vault.nix"

        # User-specific module (Hyprland config + kitty/fuzzel/waybar).
        "${superconfig}/home/taneb/hyprland.nix"

        {
          home = {
            username = "external-user";
            homeDirectory = "/home/external-user";
          };

          # Non-NixOS host.
          targets.genericLinux.enable = true;
        }
      ];
    };
  };
}
```

## Notes

- **Module files import directly.** `${superconfig}/home/…` resolves to the
  checked-out source, so a module's own relative paths (e.g. the oh-my-zsh
  theme in `home/common/core`) keep working.
- **`secrets` is required** by `home/common/core` (it reads
  `secrets.networking.hosts`). Pass your own or an empty stub.
- **`pkgs-unstable`** is only needed by `home/common/optional/vault.nix`.
- **`NH_FLAKE`** defaults to `~/config` (set with `lib.mkDefault` in core);
  override `home.sessionVariables.NH_FLAKE` if your config lives elsewhere.
- The Hyprland module ships the **config + companion apps**, not the compositor
  binary — install Hyprland yourself (e.g. `programs.hyprland.enable` on NixOS).
- On NixOS, wire the same modules through
  `home-manager.users.external-user.imports` instead of a standalone
  `homeConfigurations` entry.
