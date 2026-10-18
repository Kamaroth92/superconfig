# administrator's shared home config, applied on every host administrator is on.
{ ... }:
{
  # Determinate Nix's log format breaks nh's display; disable nom.
  home.sessionVariables.NH_NOM = "0";
}
