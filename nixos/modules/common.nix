{
  inputs,
  ...
}:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./home.nix
    ./system-packages.nix
  ];

  # sops
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "taneb"
    "root"
  ];
  nixpkgs.config.allowUnfree = true;

  # locale & time
  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # ssh
  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    openFirewall = true;
    settings.PasswordAuthentication = false;
  };

  # deploy-rs (Route A: ssh in as root). PermitRootLogin already defaults to
  # "prohibit-password", so only the key is needed.
  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRz6DYLBUKvnbvFmJbWipviwwOy3mWN6ypfuRAuGycx  deploy-key" ];

  system.stateVersion = "26.05";
}
