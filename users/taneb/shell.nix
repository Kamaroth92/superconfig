{
  config,
  ...
}:

{
  # custom oh-my-zsh theme with ssh indicator
  home.file.".oh-my-zsh/custom/themes/robbyrussell-ssh.zsh-theme".source = ./robbyrussell-ssh.zsh-theme;

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