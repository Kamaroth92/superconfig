## Deployment Examples
```
deploy .
deploy .#melchior
deploy .#wsl-builder
deploy --groups taneb .
```
```
nh os switch
nh os switch --target-host melchior -H melchior
nh home switch
```
```
sudo nixos-rebuild switch .
```

## Secrets
Stored in a private repository called `nix-secrets`.

Stores both `soft` secrets and `hard` secrets.
`soft` secrets are not sensitive configuration secrets like IP addresses where `hard` are passwords and private keys. `hard` secrets are encrypted with sops-nix where `soft` are plaintext.