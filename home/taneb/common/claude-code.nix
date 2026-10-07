# Claude Code CLI + DeepSeek provider wiring for taneb.
{
  config,
  pkgs,
  secrets,
  ...
}:
{
  # home.packages = with pkgs; [
  #   claude-code
  # ];

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
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

  # Hard secret: DeepSeek API key, encrypted in nix-secrets/sops/taneb.yaml and
  # decrypted at activation with the age key whose public half lives in
  # nix-secrets/.sops.yaml (derived from ~/.ssh/id_ed25519 via ssh-to-age).
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
