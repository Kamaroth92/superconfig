# Standalone home-manager profile, built via mkHome in flake.nix.
{
  lib,
  profiles,
  ...
}:

let
  localNix = ./local.nix;
in

{
  imports = [
    ./secrets.nix
  ]
  ++ profiles [
    "claude-code-common"
    "claude-code-deepseek"
    "common"
    "git"
    "kube"
    "rbw"
    "sops-common"
    "ssh"
    "terraform"
    "zsh-oh-my-zsh"
  ]
  ++ lib.optional (builtins.pathExists localNix) localNix;

  home.stateVersion = "26.05";

  # Short aliases for the eval/build matrix (see lib/testing.nix).
  programs.zsh.shellAliases = {
    ne = "nix run ~/config#eval -- ";
    nb = "nix run ~/config#build -- ";
  };

  home.file."repos/.keep".text = "";
}
