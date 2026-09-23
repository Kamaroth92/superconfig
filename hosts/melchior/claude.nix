{ config, pkgs, ... }:

{
  sops.secrets.deepseek-api-key = { 
    owner = config.users.users.taneb.name;
  };

  environment.variables = {
    #ANTHROPIC_AUTH_TOKEN = "$(${pkgs.coreutils}/bin/cat /run/secrets/deepseek-api-key 2>/dev/null)";
    ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
    CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-flash";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
  };

  programs.bash.shellInit = ''
    export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.deepseek-api-key.path})"
  '';
}
