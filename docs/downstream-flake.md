# Using superconfig from a downstream (private) flake

If your private dotfiles (secrets, work-specific profiles) live in a separate
repo, you can consume superconfig as a flake input and still reuse its shared
profiles and `mkHome` helper. This is how the `ffma` work machine is set up.

## Repo layout

```
config/                          # your private repo
├── flake.nix                    # references superconfig as an input
├── flake.lock
├── home/
│   └── users/
│       └── <you>/               # private profiles, secrets, overrides
│           ├── default.nix
│           └── secrets.nix
└── superconfig/                 # git submodule (optional, for local iteration)
```

superconfig itself is unchanged — your private repo wraps it.

## Step 1 — Create the private repo

```bash
mkdir ~/config && cd ~/config
git init
```

## Step 2 — Add superconfig as a submodule (optional but recommended)

A submodule lets you iterate on superconfig locally without pushing first.

```bash
git submodule add git@github.com-Kamaroth92:Kamaroth92/superconfig.git superconfig
```

If your SSH config uses a host alias for a different key (e.g.
`github.com-Kamaroth92`), use that alias in the URL — plain `github.com` will
pick up the wrong key. The `.gitmodules` entry should look like:

```ini
[submodule "superconfig"]
    path = superconfig
    url = git@github.com-Kamaroth92:Kamaroth92/superconfig.git
```

> **HTTPS won't work with host aliases.** A URL like
> `https://github.com-Kamaroth92/...` is not valid. Use SSH or plain
> `https://github.com/...`.

## Step 3 — Write your flake.nix

```nix
{
  description = "Private dotfiles";

  inputs = {
    superconfig.url = "github:Kamaroth92/superconfig";
    # Follow superconfig's nixpkgs so there is one lock for everything.
    nixpkgs.follows = "superconfig/nixpkgs";
  };

  outputs = { self, superconfig, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      homeConfigurations =
        let
          me = superconfig.lib.mkHome {
            username = "<you>";          # linux username
            hostname = "<your-host>";    # optional, for host-specific branching
            modules = [
              # Shared profiles from superconfig.
              "${superconfig}/home/profiles/base.nix"
              "${superconfig}/home/profiles/zsh-oh-my-zsh.nix"
              # ... any other shared profiles you want

              # Your private modules.
              ./home/users/<you>
            ];
          };
        in
        {
          "<you>@<your-host>" = me;
          "<you>" = me;                  # fallback key for nh
        };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
```

Key points:

- **`superconfig.lib.mkHome`** — the same helper superconfig uses internally.
  It handles `home-manager`, `sops-nix`, `targets.genericLinux`, and
  `extraSpecialArgs` (`standalone`, `hostname`, `pkgs-unstable`).
- **`"${superconfig}/home/profiles/..."`** — reference shared profiles by
  interpolating the superconfig flake input as a path.
- **`nixpkgs.follows`** — avoids a second nixpkgs eval and keeps your lock
  aligned with superconfig's.

## Step 4 — Local iteration with `--override-input`

When you're editing superconfig locally (via the submodule), you don't need to
push it to test changes. Override the flake input to point at your checkout:

```bash
nh home switch --override-input superconfig ~/config/superconfig
```

or equivalently:

```bash
home-manager switch --flake ~/config \
  --override-input superconfig path:./superconfig
```

This evaluates your local superconfig checkout instead of fetching from GitHub.

## Step 5 — Set NH_FLAKE

So that `nh home switch` (with no arguments) finds your private flake, set
`NH_FLAKE` in one of your modules:

```nix
{ lib, config, ... }:
{
  home.sessionVariables.NH_FLAKE = lib.mkForce
    "${config.home.homeDirectory}/config";
}
```

`mkForce` overrides the default that `base.nix` sets (which points at
superconfig).

## Step 6 — Bootstrap on a fresh machine

Before `home-manager` is on `PATH`:

```bash
nix run home-manager/release-26.05 -- switch --flake ~/config#<you> -b bak
```

After that, `nh home switch` works.

## Updating superconfig

```bash
cd ~/config
nix flake update superconfig    # pulls the latest commit
nh home switch                  # apply it
```

If you use the submodule for local work, also pull it:

```bash
cd ~/config/superconfig
git pull origin main
cd ..
git add superconfig
git commit -m "chore: update superconfig submodule"
```
