# taneb's shared home config, applied on every host taneb is on.
{ secrets, ... }:
{
  imports = [ ./claude-code.nix ];

  programs.git = {
    settings = {
      user = {
        name = secrets.users.taneb.userFullName;
        email = secrets.users.taneb.email;
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        identitiesOnly = "yes";
      };

      # GitHub over SSH.
      "github.com" = {
        user = "git";
      };

      # Interactive hosts.
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

      # Deploy aliases (deploy-rs wiring comes later).
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
