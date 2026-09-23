{
  config,
  pkgs,
  inputs,
  hostSecretsPath,
  ...
}:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ];

  # ── sops ────────────────────────────────────────────────
  sops.defaultSopsFormat = "yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ../secrets/common.yaml;
  sops.secrets.deepseek-api-key = {
    owner = config.users.users.taneb.name;
    sopsFile = hostSecretsPath;
  };

  # ── Nix ─────────────────────────────────────────────────
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "taneb"
    "root"
  ];
  nixpkgs.config.allowUnfree = true;

  # ── Locale & time ───────────────────────────────────────
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

  # ── SSH ─────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    openFirewall = true;
    settings.PasswordAuthentication = false;
  };

  # ── User ────────────────────────────────────────────────
  users.users."taneb" = {
    isNormalUser = true;
    description = "taneb";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      # Add your public keys here so SSH works from the start
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELUDBV8NN48h0DzhVpAmLmKT5sm+pipAPxKq7enWDwm melchior"
    ];
  };

  # ── home-manager ────────────────────────────────────────
  # NixOS config is exposed to home modules as `nixosConfig` by the
  # home-manager NixOS module itself.
  home-manager.useGlobalPkgs = true; # reuse NixOS pkgs (allowUnfree)
  home-manager.backupFileExtension = "backup";
  home-manager.users.taneb = {
    imports = [ ./home.nix ];
  };

  # ── Shared packages ─────────────────────────────────────
  environment.systemPackages = with pkgs; [
    wget
    colmena
    gnumake
    sops
    pinentry-curses
  ];

  system.stateVersion = "26.05";
}
