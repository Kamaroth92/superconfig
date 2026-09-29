# Requires secrets.nix.
{
  config,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    claude-code
  ];

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://openrouter.ai/api";
    # ANTHROPIC_MODEL = "deepseek-v4-pro[1m]";
    # ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
    # ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
    # ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";

    # Substituted by the shell when hm-session-vars.sh is sourced.
    ANTHROPIC_AUTH_TOKEN = "$(cat ${config.sops.secrets."openrouter-api-key".path})";

    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = 1;
    # CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-flash";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
  };
}
