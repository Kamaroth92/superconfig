# Bitwarden CLI (bws) + rbw.
{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.bws ];

  programs.rbw = {
    enable = true;
    settings = {
      email = "tanebarriball@gmail.com";
      lock_timeout = 3600;
      pinentry = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-curses;
    };
  };

  # macOS has no $XDG_RUNTIME_DIR (systemd-ism); rbw uses its own runtime dir
  # there, so only wire the socket up on Linux.
  home.sessionVariables = lib.mkIf (!pkgs.stdenv.isDarwin) {
    # Nothing in this repo starts rbw's ssh-agent.
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
  };
}
