# Standalone home-manager on Ubuntu WSL2.
#   nh home switch
# Identity and genericLinux come from lib/mkHome.nix.
{
  config,
  lib,
  ...
}:

let
  localNix = ./local.nix;
in

{
  imports =
    [
      ../../profiles/base.nix
      ../../profiles/zsh-oh-my-zsh.nix
      ../../profiles/kube.nix
      ../../profiles/sops.nix
      ../../profiles/claude-code.nix
    ]
    ++ lib.optional (builtins.pathExists localNix) localNix;

  home.stateVersion = "26.05";

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://7474656616847021.ai-gateway.cloud.databricks.com/anthropic";
    OTEL_RESOURCE_ATTRIBUTES = "enduser.id=bartan,user.name=bartan";
    ANTHROPIC_AUTH_TOKEN = "$(cat ${config.sops.secrets."databricks-claude-token".path})";
    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = 1;

    http_proxy = "http://localhost:3128";
    https_proxy = "http://localhost:3128";
    no_proxy = "localhost,127.0.0.1,.ffma.local,.ffma.cloud,169.254.169.254";
    HTTP_PROXY = "http://localhost:3128";
    HTTPS_PROXY = "http://localhost:3128";
    NO_PROXY = "localhost,127.0.0.1,.ffma.local,.ffma.cloud,169.254.169.254";
  };

  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

    secrets."databricks-claude-token" = {
      sopsFile = ./secrets.yaml;
    };
  };
}
