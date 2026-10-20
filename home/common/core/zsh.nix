# zsh config shared by every user.
{
  config,
  ...
}:
{
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

    # Session vars go stale after a switch; `hmreload` re-sources them.
    initContent = ''
      hmreload() {
        unset __HM_SESS_VARS_SOURCED
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      }
    '';
  };
}
