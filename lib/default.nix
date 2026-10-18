# `lib.custom` for repo-relative paths instead of fragile ../.. chains.
{ lib, ... }:
{
  relativeToRoot = lib.path.append ../.;
}
