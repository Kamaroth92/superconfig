# Melchior — desktop workstation.
{
  lib,
  ...
}:
{
  imports = [
    (lib.custom.relativeToRoot "hosts/common/core")
    ./host-spec.nix
  ];

  # Desktop, audio, networking etc. added here (and in hosts/common/optional/).
}
