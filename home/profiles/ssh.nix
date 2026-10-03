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
      "ergo-dns-01" = {
        hostname = "192.168.10.10";
        user = "administrator";
        port = "22";
      };
    };
  };
}
