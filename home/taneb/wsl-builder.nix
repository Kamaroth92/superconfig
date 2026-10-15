# taneb's home config on wsl-builder.
{ ... }:
{
  imports = [
    ../common/core
    ./common
  ];

  programs.ssh = {
    settings = {
      "deploy-melchior" = {
        hostname = "melchior";
        user = "root";
        port = "2222";
        identityfile = "~/.ssh/deploy-key";
      };
      "deploy-wsl-builder" = {
        hostname = "casper";
        user = "root";
        port = "2222";
        identityfile = "~/.ssh/deploy-key";
      };
      "deploy-ergo-dns-01" = {
        hostname = "192.168.10.10";
        user = "administrator";
        port = "22";
        identityfile = "~/.ssh/deploy-key";
      };
    };
  };
}
