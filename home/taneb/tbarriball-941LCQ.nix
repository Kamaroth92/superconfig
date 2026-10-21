# taneb's home config on the work Mac (tbarriball-941LCQ).
{ ... }:
{
  imports = [
    ../common/core
    ./common
  ];

  home = {
    username = "tane.barriball";
    homeDirectory = "/Users/tane.barriball";
  };
}
