# Shared by every user's home-manager config: shell and base tooling.
{
  config,
  ...
}:
{
  home.stateVersion = "26.05";

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

    # Session vars are guarded by __HM_SESS_VARS_SOURCED, which new shells
    # inherit, so values go stale after a switch. Run `hmreload` to pick them up.
    initContent = ''
      hmreload() {
        unset __HM_SESS_VARS_SOURCED
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      }
    '';
  };

  programs.bash.enable = true;
  programs.git.enable = true;
}
