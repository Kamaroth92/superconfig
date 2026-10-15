# Shared by every user's home-manager config: shell and base tooling.
{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
{
  home.stateVersion = "26.05";

  # nix-output-monitor: better build output on every host.
  home.packages = [ pkgs.nh ];

  # nh (nix-output-monitor / nixhelper) flake defaults. NH_HOME_FLAKE and
  # NH_OS_FLAKE default to the same flake as NH_FLAKE, but each is mkDefault so
  # a per-user or per-host module can override it with a plain value
  # (sessionVariables is an attrset, so a plain value on both sides would be a
  # merge conflict rather than an override).
  home.sessionVariables =
    let
      flake = "${config.home.homeDirectory}/config";
    in
    {
      NH_FLAKE = lib.mkDefault flake;
      NH_HOME_FLAKE = lib.mkDefault flake;
      NH_OS_FLAKE = lib.mkDefault flake;
    };

  home.file.".oh-my-zsh/custom/themes/robbyrussell-ssh.zsh-theme".source =
    ./files/robbyrussell-ssh.zsh-theme;

  # Soft-secret plumbing: private IPs from nix-secrets → ~/.config/hosts, so
  # hostnames resolve without DNS on every host — standalone home-manager hosts
  # included, where there's no NixOS /etc/hosts to touch.
  home.file.".config/hosts".text =
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: host: "${host.ip} ${name}") secrets.networking.hosts
    )
    + "\n";

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
