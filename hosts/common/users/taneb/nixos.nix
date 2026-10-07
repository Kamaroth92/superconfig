# System-user config for taneb on NixOS. Home config lives in home/taneb/.
{ ... }:
{
  extraGroups = [
    "wheel"
    "networkmanager"
  ];
  # openssh.authorizedKeys goes here once nix-secrets is wired up.
}
