# Claude Code CLI + DeepSeek provider wiring for taneb.
{
  config,
  pkgs-unstable,
  secrets,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;
    settings = {
      theme = "dark";
      enabledPlugins = {
        "nixos-managing@nixos-management-skill" = true;
        "gopls-lsp@claude-plugins-official" = true;
        "superpowers@claude-plugins-official" = true;
        "code-review@claude-plugins-official" = true;
        "skill-creator@claude-plugins-official" = true;
        "code-simplifier@claude-plugins-official" = true;
        "superpowers@superpowers-marketplace" = true;
        "frontend-design@claude-plugins-official" = true;
        "kubernetes-skill@kubernetes-skill" = true;
      };
      extraKnownMarketplaces = {
        nixos-management-skill = {
          source = {
            source = "github";
            repo = "michalzubkowicz/nixos-management-skill";
          };
        };
        kubernetes-skill = {
          source = {
            source = "github";
            repo = "LukasNiessen/kubernetes-skill";
          };
        };
      };
    };
  };

  # DeepSeek API key, decrypted from nix-secrets via sops.
  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    secrets."deepseek-api-key" = {
      sopsFile = "${secrets.outPath}/sops/taneb.yaml";
    };
  };

  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = 1;
    # Route Claude Code through DeepSeek's Anthropic-compatible endpoint.
    ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_AUTH_TOKEN = "$(cat ${config.sops.secrets."deepseek-api-key".path})";
  };
}
