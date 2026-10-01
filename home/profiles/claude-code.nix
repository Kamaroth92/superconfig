# Requires secrets.nix.
{
  config,
  pkgs-unstable,
  ...
}:

{
  home.packages = [
    pkgs-unstable.claude-code
  ];

  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = 1;
  };
}
