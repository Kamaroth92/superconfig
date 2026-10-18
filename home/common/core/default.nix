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

  home.packages = with pkgs; [
    gnumake
    nh
    nixfmt
    sops
    vim
    wget
    kitty.terminfo # xterm-kitty terminfo for SSH from kitty
  ];

  # mkDefault so a per-user/host module can override without a merge conflict.
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

  # Private IPs → ~/.config/hosts so hostnames resolve without DNS (standalone hosts have no /etc/hosts).
  home.file.".config/hosts".text =
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: host: "${host.ip} ${name}") secrets.networking.hosts
    )
    + "\n";

  # Real file, not a symlink: sshd StrictModes rejects a store symlink on non-NixOS hosts.
  home.activation.writeAuthorizedKeys =
    let
      keys = secrets.users.${config.home.username}.sshKeys or [ ];
    in
    lib.mkIf (keys != [ ]) (lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      install -m 600 -D ${builtins.toFile "authorized_keys" (lib.concatStringsSep "\n" keys + "\n")} "$HOME/.ssh/authorized_keys"
    '');

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

  programs.bash.enable = true;
  programs.git.enable = true;
}
