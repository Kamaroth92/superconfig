{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        identitiesOnly = "yes";
      };
      "melchior" = {
        user = "taneb";
        port = "2222";
      };
      "wsl-builder" = {
        hostname = "casper";
        user = "taneb";
        port = "2222";
      };
    };
  };
}
