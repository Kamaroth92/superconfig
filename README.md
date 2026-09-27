# superconfig
A Nix / .dotfiles repository for configuring multiple machines

The configuration here is heavily inspired by [p3t33's nixos_flake repository](https://github.com/p3t33/nixos_flake)

## Get keys onto the system
rbw get $USERNAME-user-key -f "public_key" > ~/.ssh/id_ed25519.pub
rbw get $USERNAME-user-key -f "private_key" > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519