# Requires secrets.nix.
{
  pkgs-unstable,
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
          kubernetes-skill = {
            source = {
              source = "github";
              repo = "LukasNiessen/kubernetes-skill";
            };
          };
        };
      };
    };
  };

  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = 1;
  };
}
