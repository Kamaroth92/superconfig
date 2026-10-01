{
  config,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.terraform
  ];
}
