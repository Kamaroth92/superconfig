# Takes over ~/.zshrc (and ~/.bashrc, ~/.profile). Use zsh-adopt.nix instead if
# those are managed outside Nix.
{
  config,
  ...
}:

{
  home.file.".oh-my-zsh/custom/themes/robbyrussell-ssh.zsh-theme".source =
    ./files/robbyrussell-ssh.zsh-theme;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      custom = "${config.home.homeDirectory}/.oh-my-zsh/custom";
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "terraform"
        "opentofu"
      ];
      theme = "robbyrussell-ssh";
    };
  };

  programs.bash.enable = true;
}
