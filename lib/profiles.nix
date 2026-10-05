# Turn profile names into their module paths so user modules import a list of
# names instead of path strings. Anchored to this repo's home/profiles and
# passed to modules as the `profiles` special argument by both home-manager
# adapters (lib/mkHome.nix and nixos/modules/home.nix).
{
  profilesDir ? ../home/profiles,
}:
names: map (name: "${profilesDir}/${name}.nix") names