{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    bws
    claude-code
    gnumake
    kubectl
    kubectx
    kubernetes-helm
    nh
    nixfmt
    sops
    vim
    wget
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "Tane Barriball";
      email = "tane.barriball@gmail.com";
    };
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "tanebarriball@gmail.com";
      lock_timeout = 3600;
      pinentry = pkgs.pinentry-curses;
    };
  };
}