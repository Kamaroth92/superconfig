{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bws
  ];

  programs.rbw = {
    enable = true;
    settings = {
      email = "tanebarriball@gmail.com";
      lock_timeout = 3600;
      pinentry = pkgs.pinentry-curses;
    };
  };

  home.sessionVariables = {
    # Nothing in this repo starts rbw's ssh-agent.
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
  };
}
