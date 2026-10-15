# Terraform.
{ pkgs, ... }:
{
  home.packages = [ pkgs.terraform ];
}
