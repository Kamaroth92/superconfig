# AGENTS.md

## Machines

NixOS hosts (`hosts/nixos/<host>/`):

- **melchior** — desktop workstation
- **wsl-builder** — NixOS-WSL builder inside `casper`

Standalone home-manager hosts (Nix on a foreign OS, no NixOS):

- **steamdeck** — user `deck`
- **ergo-dns-01** — user `administrator`
- **ergo-node-04** — users `administrator`, `ergo`

## Users

Each user's home config lives under `home/<user>/` with one entry point per host: `home/<user>/<hostname>.nix`.

- `taneb` — melchior, wsl-builder
- `deck` — steamdeck
- `administrator` — ergo-dns-01, ergo-node-04
- `ergo` — ergo-node-04

## core / common / optional

- **core** — always-imported baseline; every host/user gets it.
- **common** — shared across hosts/users.
- **optional** — opt-in modules, imported explicitly where needed.

NixOS (`hosts/`):

- `hosts/common/core` — imported by every NixOS host (home-manager wiring, sops, sshd).
- `hosts/common/optional/*.nix` — desktop/audio/bluetooth/printing/firefox; imported in a host's `default.nix`.
- `hosts/common/users/<user>/nixos.nix` — per-user system config (groups, keys).

home-manager (`home/`):

- `home/common/core` — imported by every user (shell, base tooling).
- `home/common/optional/*.nix` — shared optional tool modules.
- `home/<user>/common/default.nix` — shared by one user across all their hosts.
- `home/<user>/<hostname>.nix` — entry point; imports the above plus host-specific modules.

## Style

Keep code comments succinct and to a minimum; prefer self-explanatory names over explanatory comments.
