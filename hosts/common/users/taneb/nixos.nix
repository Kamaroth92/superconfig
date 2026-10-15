# System-user config for taneb on NixOS. Home config lives in home/taneb/.
{ secrets, ... }:
{
  description = "taneb";
  extraGroups = [
    "wheel"
    "networkmanager"
  ];

  # Public key for `ssh <host>` as taneb (already merged with the common bucket
  # by the nix-secrets flake).
  openssh.authorizedKeys.keys = secrets.users.taneb.sshKeys;
}
