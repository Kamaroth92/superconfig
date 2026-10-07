# System-user config for deck on NixOS. Home config lives in home/deck/.
# Only relevant if the Steam Deck ever becomes NixOS; for now deck is a
# home-manager-only user on SteamOS.
{ ... }:
{
  extraGroups = [ "wheel" ];
}
