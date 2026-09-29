{
  config,
  ...
}:

{
  # sops (user secrets)
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

  # session variables
  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://openrouter.ai/api";
    # ANTHROPIC_MODEL = "deepseek-v4-pro[1m]";
    # ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
    # ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
    # ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
    ANTHROPIC_AUTH_TOKEN = "$(cat ${config.sops.secrets."openrouter-api-key".path})";
    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1;
    # CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-flash";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
    KUBECONFIG = config.sops.secrets."kubeconfig".path;
    NH_FLAKE = "${config.home.homeDirectory}/config";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
  };
}