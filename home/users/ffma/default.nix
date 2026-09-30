{ inputs, ... }:

{
  imports = [
    ../../profiles/base.nix
    ../../profiles/zsh-oh-my-zsh.nix
    ../../profiles/kube.nix
    ../../profiles/sops.nix
    ../../profiles/claude-code.nix
    ../../profiles/vault.nix
    inputs.ffma-nix.homeManagerModules.ffma
  ];
}
