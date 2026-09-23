{
  config,
  pkgs,
  nixosConfig,
  ...
}:

{
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    vim
    git
    rbw
    claude-code
    bitwarden-cli
    nixfmt
  ];

  programs.bash = {
    enable = true;
    initExtra = ''
      export ANTHROPIC_AUTH_TOKEN="$(cat ${nixosConfig.sops.secrets.deepseek-api-key.path})"
    '';
  };

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
    CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-flash";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
  };
}
