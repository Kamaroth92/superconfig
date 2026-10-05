# Requires a key that can decrypt home/users/taneb/*.yaml. Decryption runs
# as a systemd user service, so without one these paths never appear.
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

    secrets."openrouter-api-key" = {
      sopsFile = ./secrets.yaml;
    };
    secrets."deepseek-api-key" = {
      sopsFile = ./secrets.yaml;
    };
  };

  # home.sessionVariables = {
  #   # Read-only, so kubectx cannot write to it.
  #   KUBECONFIG = config.sops.secrets."kubeconfig".path;
  # };
}
