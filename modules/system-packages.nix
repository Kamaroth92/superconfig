{
  pkgs,
  ...
}:

{
  # git stays at the system level so it is available before home-manager is
  environment.systemPackages = with pkgs; [
    git
  ];
}
