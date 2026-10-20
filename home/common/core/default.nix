# Shared by every user's home-manager config: shell and base tooling.
{ ... }:
{
  imports = [
    ./base.nix
    ./files.nix
    ./ssh.nix
    ./zsh.nix
    ./git-aliases.nix
  ];

  home.stateVersion = "26.05";

  programs.bash.enable = true;
  programs.git.enable = true;
}
