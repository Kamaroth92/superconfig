# administrator's shared home config, applied on every host administrator is on.
{ ... }:
{
  # This user runs Determinate Nix, whose internal-json log format emits
  # activity types that nix-output-monitor (nh's build display) can't parse,
  # spamming errors on every build. Disable nom here.
  home.sessionVariables.NH_NOM = "0";
}
