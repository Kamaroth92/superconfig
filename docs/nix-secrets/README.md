# nix-secrets

A separate git repo (outside this one) holding the secrets this config
consumes. Two kinds live in it:

- **Soft secrets** — plain flake outputs (`networking`, `users`), read as
  `secrets.networking.hosts` etc. Not sensitive enough to encrypt.
- **Hard secrets** — sops-encrypted files in `sops/`, decrypted at activation
  by sops-nix using an age key derived from an SSH key.

## Repo layout

```
nix-secrets/
├── flake.nix
├── .sops.yaml
└── sops/
    ├── kubeconfig.yaml
    └── external-user.yaml
```

## flake.nix — soft secrets

```nix
{
  description = "Soft + hard secrets for the config";

  outputs = { self }: {
    # Soft secrets, exposed as flake outputs and read as `secrets.*`.
    networking = {
      hosts = {
        melchior = { ip = "10.0.0.10"; };
        ergo-dns-01 = { ip = "192.168.10.10"; };
      };
    };

    users = {
      external-user = {
        userFullName = "External User";
        email = "external-user@example.com";
        sshKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."
        ];
      };
    };
  };
}
```

## .sops.yaml — who can decrypt

The age public key must match the SSH key sops-nix decrypts with
(`sops.age.sshKeyPaths`); generate it with `ssh-to-age`.

```yaml
keys:
  - &external_user age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8xmujr0g3whx9qq8n0m5v

creation_rules:
  - path_regex: sops/.*\.yaml$
    key_groups:
      - age:
          - *external_user
```

## A hard secret

Committed encrypted (what `sops` produces):

```yaml
kubeconfig: ENC[AES256_GCM,data:...,iv:...,tag:...,type:str]
sops:
  age:
    - recipient: age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8xmujr0g3whx9qq8n0m5v
      enc: |
        -----BEGIN AGE ENCRYPTED FILE-----
        ...
        -----END AGE ENCRYPTED FILE-----
  mac: ENC[AES256_GCM,data:...,iv:...,tag:...,type:str]
```

Decrypts to:

```yaml
kubeconfig: |
  apiVersion: v1
  kind: Config
  clusters: []
```

## Wiring it into this repo

Add it as a flake input (local checkout, or `git+ssh:`), pass it to modules as
`secrets`, and reference hard secrets via `secrets.outPath`:

```nix
# flake.nix (this repo)
inputs.nix-secrets.url = "path:/home/external-user/repos/nix-secrets";
# inputs.nix-secrets.url = "git+ssh://git@github.com/external-user/nix-secrets.git";

# in outputs:
secrets = nix-secrets;

# pass down:
specialArgs = { inherit secrets; };       # NixOS
extraSpecialArgs = { inherit secrets; };  # home-manager
```

```nix
# consume soft secrets
secrets.networking.hosts.<host>.ip
secrets.users.<user>.sshKeys / .userFullName / .email

# consume a hard secret
sops.secrets.kubeconfig = {
  sopsFile = "${secrets.outPath}/sops/kubeconfig.yaml";
};
```

## Notes

- `path:` inputs are content-addressed — after editing nix-secrets, run
  `nix flake lock --update-input nix-secrets` or the changes are ignored.
- Decryption keys differ per consumer: NixOS hosts use their SSH host key,
  home-manager uses the user's `~/.ssh/id_ed25519`.
