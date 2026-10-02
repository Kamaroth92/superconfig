# Not for users whose ~/.gitconfig is managed outside Nix.
{ ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Tane Barriball";
      email = "tanebarriball@gmail.com";
    };
  };

  programs.ssh = {
    settings = {
      "github.com" = {
        user = "git";
      };
      "github.com-ffma-tane-barriball" = {
        hostname = "github.com";
        user = "git";
        identityfile = "~/.ssh/Github-ffma-tane-barriball";
      };
    };
  };
}
