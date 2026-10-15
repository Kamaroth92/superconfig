# Small custom lib exposed to modules as `lib.custom`, so modules reference files
# by repo-relative path instead of fragile ../.. chains.
{ lib, ... }:
{
  relativeToRoot = lib.path.append ../.;
}
