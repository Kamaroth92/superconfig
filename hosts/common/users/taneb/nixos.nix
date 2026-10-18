# System-user config for taneb on NixOS. Home config lives in home/taneb/.
{ secrets, ... }:
{
  description = "taneb";
  extraGroups = [
    "wheel"
    "networkmanager"
  ];

  # taneb's ssh keys (merged with the common bucket).
  openssh.authorizedKeys.keys = secrets.users.taneb.sshKeys;
}
