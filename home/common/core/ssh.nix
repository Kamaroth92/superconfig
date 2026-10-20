# SSH authorized_keys for every user.
{
  config,
  lib,
  secrets,
  ...
}:
{
  # Real file, not a symlink: sshd StrictModes rejects a store symlink on non-NixOS hosts.
  home.activation.writeAuthorizedKeys =
    let
      keys = secrets.users.${config.home.username}.sshKeys or [ ];
    in
    lib.mkIf (keys != [ ]) (
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        install -m 600 -D ${
          builtins.toFile "authorized_keys" (lib.concatStringsSep "\n" keys + "\n")
        } "$HOME/.ssh/authorized_keys"
      ''
    );
}
