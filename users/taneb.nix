{
  config,
  pkgs,
  nixosConfig,
  ...
}:

{
  imports = [
    ../modules/home.nix
  ];

  home.packages = with pkgs; [
    claude-code
    bitwarden-cli
  ];

  programs = {
    bash = {
      enable = true;
      initExtra = ''
        export ANTHROPIC_AUTH_TOKEN="$(cat ${nixosConfig.sops.secrets.deepseek-api-key.path})"
      '';
    };
    git = {
      enable = true;
      settings.user = {
        name = "Tane Barriball";
        email = "tane.barriball@gmail.com";
      };
    };
    rbw = {
      settings = {
        email = "tanebarriball@gmail.com";
        settings.pinentry = "pinentry-curses";
      };
    };
  };

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
    CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-flash";
    CLAUDE_CODE_EFFORT_LEVEL = "max";

    SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
  };
}
