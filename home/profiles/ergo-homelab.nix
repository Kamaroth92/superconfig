

{ pkgs, ... }:
let
  commonSecretsPath = "${config.home.homeDirectory}/config/home/secrets/common";
{
  home.packages = with pkgs; [ ];

  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

    secrets."kubeconfig" = {
      sopsFile = "${commonSecretsPath}/kubeconfig.yaml";
    };
  };

  home.sessionVariables = { };
}
