# taneb's shared home config, applied on every host taneb is on.
{
  config,
  inputs,
  pkgs,
  secrets,
  ...
}:
{
  imports = [
    ./claude-code.nix
    ../../common/optional/aws.nix
    ../../common/optional/kube.nix
    ../../common/optional/terraform.nix
    ../../common/optional/vault.nix
    ../../common/optional/rbw.nix
  ];

  # deploy-rs CLI for remote deploys (see the `deploy` output in flake.nix).
  home.packages = [
    inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.deploy-rs
  ];

  # taneb's cluster kubeconfig, decrypted from nix-secrets/sops/kubeconfig.yaml.
  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    secrets.kubeconfig = {
      sopsFile = "${secrets.outPath}/sops/kubeconfig.yaml";
    };
  };
  home.sessionVariables.KUBECONFIG = config.sops.secrets.kubeconfig.path;

  programs.git = {
    settings = {
      user = {
        name = secrets.users.taneb.userFullName;
        email = secrets.users.taneb.email;
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        identitiesOnly = "yes";
      };

      "github.com" = {
        user = "git";
      };

      "melchior" = {
        user = "taneb";
        port = "2222";
      };
      "wsl-builder" = {
        hostname = "casper";
        user = "taneb";
        port = "2222";
      };
      "ergo-dns-01" = {
        hostname = "192.168.10.10";
        user = "administrator";
        port = "22";
      };
    };
  };
}
