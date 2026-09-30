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
}
