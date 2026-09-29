# Requires a key that can decrypt secrets/*.yaml. Decryption runs as a systemd
# user service, so without one these paths never appear.
{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    sops
  ];

  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

    secrets."deepseek-api-key" = {
      sopsFile = ../../secrets/taneb.yaml;
    };
    secrets."openrouter-api-key" = {
      sopsFile = ../../secrets/taneb.yaml;
    };
    secrets."kubeconfig" = {
      sopsFile = ../../secrets/kubeconfig.yaml;
    };
  };

  home.sessionVariables = {
    # Read-only, so kubectx cannot write to it.
    KUBECONFIG = config.sops.secrets."kubeconfig".path;
  };
}
