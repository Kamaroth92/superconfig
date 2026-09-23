{ config, pkgs, ... }:

{
  sops.secrets.deepseek-api-key = { };

  environment.variables = {
    ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_MODEL = "deepseek-flash";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-flash";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-flash";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-flash";
    CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-flash";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
  };

  programs.bash.shellInit = ''
    export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.deepseek-api-key.path})"
  '';
}
