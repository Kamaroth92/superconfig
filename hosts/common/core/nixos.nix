# Core functionality shared by every NixOS host.
{
  config,
  lib,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Australia/Melbourne";
  i18n.defaultLocale = "en_AU.UTF-8";

  system.stateVersion = "26.05";

  # Hard secrets (sops-nix) are decrypted with each host's SSH host key. Add
  # sops.defaultSopsFile and sops.secrets.<name> once the encrypted files exist
  # in nix-secrets/sops/.
  sops = {
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # Soft secrets in action: private IPs from nix-secrets become /etc/hosts
  # entries, so hostnames resolve without DNS.
  networking.extraHosts = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: host: "${host.ip} ${name}") config.hostSpec.networking.hosts
  );
}
