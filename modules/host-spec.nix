# hostSpec option — a host describes itself in hosts/nixos/<host>/host-spec.nix.
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
        touchpad = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.submodule {
              options = {
                vendor = lib.mkOption {
                  type = lib.types.int;
                  description = "Touchpad vendor id (decimal).";
                };
                product = lib.mkOption {
                  type = lib.types.int;
                  description = "Touchpad product id (decimal).";
                };
                name = lib.mkOption {
                  type = lib.types.str;
                  description = "Touchpad device name, as KDE/libinput reports it.";
                };
              };
            }
          );
          default = null;
          description = "Touchpad hardware identity for KDE kcminputrc, if this host has one.";
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
