# tbarriball-941LCQ — work MacBook (nix-darwin).
{ lib, ... }:
{
  imports = [
    (lib.custom.relativeToRoot "hosts/darwin/common/core")
    ./host-spec.nix
  ];
}
