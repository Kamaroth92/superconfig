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
        User = "git";
      };
      "github.com-ffma-tane-barriball" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/Github-ffma-tane-barriball";
      };
    };
  };
}

# Host github.com
#     HostName github.com
#     User git
#     IdentityFile ~/.ssh/id_ed25519
#     IdentitiesOnly yes
# Host github.com-ffma-tane-barriball
#     HostName github.com
#     User git
#     IdentityFile ~/.ssh/Github-ffma-tane-barriball
#     IdentitiesOnly yes