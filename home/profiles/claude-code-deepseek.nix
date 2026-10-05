{
  config,
  ...
}:

{
  home.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_AUTH_TOKEN = "$(cat ${config.sops.secrets."deepseek-api-key".path})";
  };

  programs.claude-code.settings = {
    # model = "deepseek-pro-latest[1m]";
    # modelPicker = {
    #   options = [
    #     {
    #       model = "~deepseek/deepseek-pro-latest[1m]";
    #       label = "DeepSeek Pro";
    #       description = "DeepSeek Pro via OpenRouter (latest)";
    #     }
    #     {
    #       model = "~deepseek/deepseek-flash-latest[1m]";
    #       label = "DeepSeek Flash";
    #       description = "DeepSeek Flash via OpenRouter (latest)";
    #     }
    #   ];
    #   replaceBuiltInOptions = false;
    # };
  };
}
