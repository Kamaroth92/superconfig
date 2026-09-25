# Secrets restructure: per-user and per-machine secrets

Date: 2026-09-24

## Context

The repo currently stores one user secret (`deepseek-api-key`) duplicated in each
host's secret file (`secrets/melchior.yaml`, `secrets/wsl-builder.yaml`), routed
through a `hostSecretsPath` specialArg. This means every host key can decrypt
every user's secrets, and adding a user or a machine means re-encrypting files.

Goal: keep the existing `hosts/`/`users/`/`modules/` structure, but reorganize
the secrets layer so that:

- user secrets live in per-user files, encrypted to that user's own age key —
  host keys never touch user secrets
- machine secrets live in shared (`common.yaml`) and per-host files
  (`melchior.yaml`, `wsl-builder.yaml`), encrypted to host keys
- adding a machine or a user does not require re-encrypting existing user files

## Target layout

```
secrets/
  common.yaml           # shared machine secrets → host keys + user pubkeys
  melchior.yaml         # melchior machine secrets → melchior key (+ bootstrap user keys)
  wsl-builder.yaml      # wsl-builder machine secrets → wsl-builder key (+ bootstrap user keys)
  users/
    taneb.yaml          # taneb's secrets (deepseek-api-key) → taneb's age key
modules/
  common.nix            # shared system config; sops default = common.yaml
  home.nix              # unchanged
users/
  taneb.nix             # self-contained home config with its own sops setup
hosts/                  # unchanged layout; each host file gains a bootstrap stanza
```

Deleted: `modules/configuration.nix` (dead, not imported anywhere), the stale
`secrets/secrets.yaml` creation rule in `.sops.yaml`.

## Encryption model

| File | Encrypted to | Decrypted by |
| --- | --- | --- |
| `common.yaml` | all host keys + user pubkeys | sops-nix at system level (default file) |
| `melchior.yaml` | melchior key | sops-nix at system level (per-secret `sopsFile`) |
| `wsl-builder.yaml` | wsl-builder key | sops-nix at system level (per-secret `sopsFile`) |
| `users/taneb.yaml` | taneb's age key | home-manager sops module |

- Host files never hold user secrets; user files never hold machine secrets.
- User pubkeys are added to `common.yaml`'s key group so users can `sops edit`
  shared machine secrets with their own key. User pubkeys are NOT added to
  per-host file rules.
- A host can read a user's secrets only if that user's age key was provisioned
  to it via the bootstrap mechanism below.

## Secret mechanics

### Per-user secrets (home-manager sops)

`users/taneb.nix` imports `inputs.sops-nix.homeManagerModules.sops` and declares:

```nix
sops = {
  defaultSopsFile = ../secrets/users/taneb.yaml;
  age.keyFile = "${nixosConfig.sops.secrets.taneb-age-key.path}";
  age.generateKey = false;   # fail loudly instead of silently generating a wrong key
};
sops.secrets.deepseek-api-key = { };
```

The bash init reads `config.sops.secrets.deepseek-api-key.path` (decrypted under
`~/.config/sops-nix/secrets/`). No username-prefixed names are needed: each
user's home config is its own namespace, so secret names cannot collide between
users.

### Bootstrap: provisioning the user's age key

Each user has one age keypair. The private key is committed only in encrypted
form, inside the machine files of the hosts that user logs into:

```nix
# hosts/melchior/default.nix (wsl-builder analogous, with its own sopsFile)
sops.secrets.taneb-age-key = {
  sopsFile = ../../secrets/melchior.yaml;
  owner = "taneb";
  mode = "0400";
};
```

sops-nix decrypts it at boot (host ssh key) to `/run/secrets/taneb-age-key`,
which the home-manager sops module uses as its `keyFile`. This is the documented
sops-nix pattern for system-provisioned user keys.

Consequences, accepted explicitly:

- A host with root access can decrypt the user keys provisioned to it (and
  therefore those users' secrets on that host). This is the agreed boundary.
- A host without a user's bootstrap stanza cannot decrypt that user's secrets.
- Adding a machine: add its key to `common.yaml` and create its own host file
  with bootstrap stanzas. Existing user files are untouched.
- Adding a user: `age-keygen`, add their pubkey anchor + creation rule to
  `.sops.yaml`, create `secrets/users/<name>.yaml`, add a bootstrap stanza to
  each host they use.

### Machine secrets

- Shared: `sops.defaultSopsFile = ../secrets/common.yaml` in `modules/common.nix`
  (unchanged from today).
- Per-host: declared in the host module with a relative path, e.g.
  `sops.secrets.<x> = { sopsFile = ../../secrets/melchior.yaml; };`. No
  specialArgs plumbing.

## Per-file changes

- **`.sops.yaml`**: add `&taneb_user` anchor; add rule
  `secrets/users/taneb\.yaml$` → `[*taneb_user]`; add `*taneb_user` to the
  `common.yaml` key group; remove stale `secrets/secrets.yaml` rule; normalize
  indentation of existing rules.
- **`flake.nix`**: delete `hostSecretsPath` from both nixosConfiguration
  specialArgs; delete `colmena.meta.nodeSpecialArgs` entirely.
- **`modules/common.nix`**: drop `hostSecretsPath` arg and the
  `sops.secrets.deepseek-api-key` block; add
  `home-manager.extraSpecialArgs = { inherit inputs; };`. Everything else
  (including the hardcoded `users.users.taneb`) stays.
- **`users/taneb.nix`**: add the sops home module import and config shown above;
  bash init switches to `config.sops.secrets.deepseek-api-key.path`.
- **`hosts/melchior/default.nix`, `hosts/wsl-builder/default.nix`**: add the
  `taneb-age-key` bootstrap stanza shown above.
- **`modules/configuration.nix`**: deleted.

## Migration steps

1. Generate taneb's age keypair (`age-keygen`). Public key → `.sops.yaml` (new
   anchor, `users/` rule, `common.yaml` key group).
2. Create `secrets/users/taneb.yaml` with `deepseek-api-key`, encrypted to
   taneb's user key (the `.sops.yaml` creation rule must be in place first).
3. Edit host yamls via sops: remove `deepseek-api-key`, add `taneb-age-key`
   (the private key value).
4. Apply the code changes from the previous section.
5. Delete `modules/configuration.nix`.

Secret edits are done with the local sops keys where available; otherwise the
owner runs the sops commands.

## Testing

- `nix flake check` — formatting and evaluation of the whole flake (this also
  evaluates the wsl-builder configuration, which must stay valid even though
  the machine is offline).
- `nixos-rebuild dry-build --flake .#melchior`.
- After applying on melchior:
  - `/run/secrets/taneb-age-key` exists, owned by taneb, mode 0400.
  - `~/.config/sops-nix/secrets/deepseek-api-key` decrypts for taneb.
  - A fresh bash session has `ANTHROPIC_AUTH_TOKEN` set.
- wsl-builder is offline; it is not tested. Its config is applied whenever it
  is next reachable, with the same checks as melchior.

## Future extensions (out of scope)

- Parametrizing `users.users` / `home-manager.users` over a user list in
  `common.nix` when a second user arrives.
- Refining the `secrets/users/` creation rules per user if a future user only
  logs into a subset of hosts.
