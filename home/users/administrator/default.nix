# Standalone home-manager profile, built via mkHome in flake.nix.
# Also reusable on NixOS later via home-manager.users.administrator.
{
  lib,
  profiles,
  ...
}:

let
  localNix = ./local.nix;
in

{
  imports =
    profiles [
      "common"
      "git"
      "rbw"
      "sops-common"
      "ssh"
      "zsh-oh-my-zsh"
    ]
    ++ lib.optional (builtins.pathExists localNix) localNix;

  home.stateVersion = "26.05";

  # This host runs Determinate Nix, whose internal-json log format emits
  # activity types that nix-output-monitor (nh's build display) can't parse,
  # spamming errors on every build. Disable nom here.
  home.sessionVariables.NH_NOM = "0";

  home.file."repos/.keep".text = "";

  # Authorized keys for this account, for hosts without NixOS (ssh keys are
  # managed via users.users.*.openssh.authorizedKeys on NixOS hosts).
  home.file.".ssh/authorized_keys".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPE+hjAIQBKvf3GxYrcX4ImpbPPz17ZdCpL4C8a3Hif taneb-user-key
  '';
}
