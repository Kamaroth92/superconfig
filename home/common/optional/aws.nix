# AWS CLI.
{ pkgs, ... }:
{
  home.packages = [ pkgs.awscli2 ];
}
