# Not for users whose ~/.gitconfig is managed outside Nix.
{ ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Tane Barriball";
      email = "tane.barriball@gmail.com";
    };
  };
}
