# Core functionality shared by every NixOS host.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Trusted users can build remotely (nh os switch --target-host).
  nix.settings.trusted-users = [
    "taneb"
    "root"
  ];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";

  # xterm-kitty terminfo for SSH sessions from kitty.
  environment.systemPackages = [ pkgs.kitty.terminfo ];

  system.stateVersion = "26.05";

  # Hard secrets (sops-nix) are decrypted with each host's SSH host key.
  sops = {
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    openFirewall = true;
    settings.PasswordAuthentication = false;
  };

  # VS Code Server links against glibc/libstdc++; run through nix-ld.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ stdenv.cc.cc.lib ];
  };

  # Root ssh for deploy-rs (PermitRootLogin defaults to key-only).
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRz6DYLBUKvnbvFmJbWipviwwOy3mWN6ypfuRAuGycx deploy-key"
  ];

  # Hostnames resolve without DNS.
  networking.extraHosts = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: host: "${host.ip} ${name}") config.hostSpec.networking.hosts
  );
}
