# Not for users whose ~/.gitconfig is managed outside Nix.
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
        hostname = "melchior";
        user = "taneb";
        port = "2222";
      };
    };
  };
}
