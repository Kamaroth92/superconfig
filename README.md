# superconfig
A Nix / .dotfiles repository for configuring multiple machines

The configuration here is heavily inspired by [p3t33's nixos_flake repository](https://github.com/p3t33/nixos_flake)

## Layout

The repo serves two kinds of machine from one set of user-level modules.

| path | purpose |
| --- | --- |
| `home/profiles/` | portable home-manager modules. **No NixOS options, no `nixpkgs.config`.** |
| `home/users/` | per-user identity plus a list of profiles to import |
| `lib/mkHome.nix` | adapter for standalone home-manager (non-NixOS hosts) |
| `modules/` | NixOS-only modules, including the NixOS-side home-manager adapter |
| `machines/` | one directory per NixOS host |
| `users/` | NixOS-level user accounts |

Anything under `home/` must evaluate on both paths, so it may not reference
`users.users`, `environment.systemPackages`, `services.*`, `nix.settings`, or set
`nixpkgs.config` / `nixpkgs.overlays`. Options that only make sense without a
NixOS system underneath — `targets.genericLinux` in particular — belong in
`lib/mkHome.nix`.

To branch on how a module is being delivered, use the `standalone` argument
passed through `extraSpecialArgs` by both adapters. Do not probe for `osConfig`.

## NixOS hosts

`melchior`, `wsl-builder`. home-manager is attached as a NixOS module, so
`nixos-rebuild` applies both layers at once. `NH_FLAKE` is set, so:

```
nh os switch
```

## Non-NixOS hosts

`ffma` — Ubuntu 24.04 under WSL2. Only `$HOME` is managed; apt owns the system.

```
nh home switch
```

Standalone configurations are keyed `<user>@<hostname>`, e.g.
`ffma@FF-5CG30956H8`. That is the attribute `nh home switch` looks for first when
given no `-c`; it falls back to a bare `<user>`, and a short alias is defined for
each host, so all three of these are equivalent:

```
nh home switch
home-manager switch --flake ~/config#ffma@FF-5CG30956H8
home-manager switch --flake ~/config#ffma
```

`nh` reads `NH_FLAKE`, which `home/profiles/base.nix` sets to `~/config`, so it
needs no flake argument. Adding a second machine for the same user means another
`mkHome` call with a different `hostname`; the `user@host` key keeps them apart.
Modules can branch on the host via the `hostname` argument that `lib/mkHome.nix`
passes through `extraSpecialArgs`.

### First-time setup

Nix must be installed and flakes enabled. Ubuntu's `nix-bin` package is **not**
suitable — it is too old for a `release-26.05` home-manager, and it restricts
daemon access to the `nix-users` group. Use the Determinate installer:

```
sudo apt-get purge --auto-remove nix-bin nix-setup-systemd
sudo rm -rf /nix /etc/nix
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

It enables `nix-command` and `flakes` by default. WSL needs `systemd=true` in
`/etc/wsl.conf` first, which is the Ubuntu 24.04 default.

Then bootstrap, before `home-manager` is on `PATH`:

```
nix run home-manager/release-26.05 -- switch --flake ~/config#ffma -b bak
```

`-b bak` moves conflicting unmanaged files aside rather than failing. Delete the
`.bak` files afterwards — a second switch fails if they are still present.

## Get keys onto the system
```
rbw get $USERNAME-user-key -f "public_key" > ~/.ssh/id_ed25519.pub  
rbw get $USERNAME-user-key -f "private_key" > ~/.ssh/id_ed25519  
chmod 600 ~/.ssh/id_ed25519
```

# Furture state
Ideally this configuration will be used to manage multiple machines with different purposes
WSL: taneb (NixOS-WSL), ffma (Ubuntu WSL, standalone home-manager)
Laptop: taneb
Ergo Nodes 1 / 2 / 3: ergo and taneb
Other machines not running nixos
