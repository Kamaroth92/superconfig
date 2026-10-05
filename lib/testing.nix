# On-demand evaluation and building of the flake's configured machines, derived
# at build time so a new user or machine needs no update here.
#
#   nix run .#eval -- <target>    evaluate (module system resolves, no build)
#   nix run .#build -- <target>   actually build the closure
#   nix run .#eval-all / .#build-all   shorthand for `all`
#
# Targets are the keys on homeConfigurations and nixosConfigurations:
#   all            every home + nixos configuration
#   <user>@<host>  one home configuration
#   <user>         every home key for that username (bare key + <user>@*)
#   <host>         the NixOS configuration on that host
{
  pkgs,
  self,
}:
let
  inherit (pkgs) lib;

  homeNames = builtins.attrNames self.homeConfigurations;
  nixosNames = builtins.attrNames self.nixosConfigurations;

  nixBin = "${pkgs.nix}/bin/nix";
  flake = toString self.outPath;

  mkScript = verb: pkgs.writeShellScriptBin "check-matrix-${verb}" ''
    set -euo pipefail

    verb=${verb}
    nix_bin=${lib.escapeShellArg nixBin}
    flake=${lib.escapeShellArg flake}
    home_targets=(${lib.escapeShellArgs homeNames})
    nixos_targets=(${lib.escapeShellArgs nixosNames})

    fail=0

    home_cmd() {
      case "$verb" in
        eval)  "$nix_bin" eval  --no-write-lock-file "$flake#homeConfigurations.\"$1\".activationPackage.drvPath" ;;
        build) "$nix_bin" build --no-link --no-write-lock-file "$flake#homeConfigurations.\"$1\".activationPackage" ;;
      esac
    }
    nixos_cmd() {
      case "$verb" in
        eval)  "$nix_bin" eval  --no-write-lock-file "$flake#nixosConfigurations.\"$1\".config.system.build.toplevel.drvPath" ;;
        build) "$nix_bin" build --no-link --no-write-lock-file "$flake#nixosConfigurations.\"$1\".config.system.build.toplevel" ;;
      esac
    }

    run_home() {
      local t="$1" out
      if out=$(home_cmd "$t" 2>/dev/null); then
        if [ "$verb" = eval ]; then printf '%-24s %s\n' "$t" "$out"; else printf '%-24s built\n' "$t"; fi
      else
        printf '%-24s FAILED\n' "$t"
        home_cmd "$t" 2>&1 | sed 's/^/    /' >&2
        fail=1
      fi
    }
    run_nixos() {
      local t="$1" out
      if out=$(nixos_cmd "$t" 2>/dev/null); then
        if [ "$verb" = eval ]; then printf '%-24s %s\n' "$t" "$out"; else printf '%-24s built\n' "$t"; fi
      else
        printf '%-24s FAILED\n' "$t"
        nixos_cmd "$t" 2>&1 | sed 's/^/    /' >&2
        fail=1
      fi
    }

    usage() {
      echo "usage: $0 <target>" >&2
      echo "  all            every home + nixos configuration" >&2
      echo "  <user>@<host>  one home configuration" >&2
      echo "  <user>         every home configuration for that username" >&2
      echo "  <host>         the NixOS configuration on that host" >&2
      echo "home targets:   ''${home_targets[*]}" >&2
      echo "nixos targets:  ''${nixos_targets[*]}" >&2
      exit 2
    }

    target="''${1:-}"
    if [ -z "$target" ]; then target=all; fi

    if [ "$target" = all ]; then
      for t in "''${home_targets[@]}"; do run_home "$t"; done
      for t in "''${nixos_targets[@]}"; do run_nixos "$t"; done
    elif [[ "$target" == *@* ]]; then
      run_home "$target"
    else
      matched=0
      if [[ " ''${nixos_targets[*]} " == *" $target "* ]]; then
        run_nixos "$target"; matched=1
      fi
      for t in "''${home_targets[@]}"; do
        if [[ "$t" == "$target" || "$t" == "$target"@* ]]; then
          run_home "$t"; matched=1
        fi
      done
      if [ "$matched" = 0 ]; then usage; fi
    fi

    exit "$fail"
  '';

  evalScript = mkScript "eval";
  buildScript = mkScript "build";

  app = script: bin: {
    type = "app";
    program = "${script}/bin/${bin}";
  };
in
{
  apps = {
    eval = app evalScript "check-matrix-eval";
    eval-all = app evalScript "check-matrix-eval";
    build = app buildScript "check-matrix-build";
    build-all = app buildScript "check-matrix-build";
  };
}