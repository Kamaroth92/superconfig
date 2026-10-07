# A host describes itself in one place: hosts/nixos/<hostname>/host-spec.nix.
# Core modules read hostSpec to derive networking.hostName, the system users to
# create, and the home-manager users to wire up. Minimal subset of EmergentMind's
# modules/hosts/common/host-spec.nix.
{
  lib,
  ...
}:
{
  options.hostSpec = lib.mkOption {
    type = lib.types.submodule {
      options = {
        hostName = lib.mkOption {
          type = lib.types.str;
          description = "Hostname of the machine";
        };
        users = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Users provisioned on this host";
        };
        networking = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          description = "Network details (soft secrets) for this host's subnet";
        };
      };
    };
    default = { };
  };
}
