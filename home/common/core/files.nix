# Dotfiles shared by every user.
{
  lib,
  secrets,
  ...
}:
{
  home.file.".oh-my-zsh/custom/themes/robbyrussell-ssh.zsh-theme".source =
    ./files/robbyrussell-ssh.zsh-theme;

  # Private IPs → ~/.config/hosts so hostnames resolve without DNS (standalone hosts have no /etc/hosts).
  home.file.".config/hosts".text =
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: host: "${host.ip} ${name}") secrets.networking.hosts
    )
    + "\n";
}
