{
  ...
}:

{
  home.stateVersion = "26.05";

  imports = [
    ./shell.nix
    ./env.nix
    ./programs.nix
  ];

  home.file."repos/.keep".text = "";
}