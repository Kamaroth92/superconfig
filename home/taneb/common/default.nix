# taneb's shared home config, applied on every host taneb is on.
{ ... }:
{
  programs.git = {
    settings = {
      user = {
        name = "Tane Barriball";
        email = "tanebarriball@gmail.com";
      };
    };
  };
}
