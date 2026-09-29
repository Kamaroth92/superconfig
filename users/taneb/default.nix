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

  # zsh is the login shell; home-manager (shell.nix) configures it, so the
  # system default prompt is left empty.
  programs.zsh.enable = true;
  programs.zsh.promptInit = "";

  # home-manager
  home-manager.users."taneb".imports = [ ./home.nix ];
}