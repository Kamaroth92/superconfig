# System-user config for administrator on NixOS. Home config lives in
# home/administrator/. Only relevant once the ergo hosts become NixOS; for now
# administrator is a home-manager-only user.
{ ... }:
{
  extraGroups = [ "wheel" ];
}
