# System-user config for taneb on NixOS. Home config lives in home/taneb/.
{ ... }:
{
  extraGroups = [
    "wheel"
    "networkmanager"
  ];

  # Public key for `ssh <host>` as taneb.
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPE+hjAIQBKvf3GxYrcX4ImpbPPz17ZdCpL4C8a3Hif taneb-user-key"
  ];
}
