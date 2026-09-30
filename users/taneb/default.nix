{
  pkgs,
  ...
}:

{
  # user account
  users.users."taneb" = {
    isNormalUser = true;
    description = "taneb";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPE+hjAIQBKvf3GxYrcX4ImpbPPz17ZdCpL4C8a3Hif taneb-user-key"
    ];
    shell = pkgs.zsh;
  };

  # home-manager owns the prompt.
  programs.zsh.enable = true;
  programs.zsh.promptInit = "";

  # Delivered via NixOS module (see modules/home.nix) so `nh os switch`
  # applies dotfiles too. Also available standalone via `nh home switch`.
  home-manager.users.taneb = { imports = [ ../../home/users/taneb ]; };
}
