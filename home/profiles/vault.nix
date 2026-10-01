# Requires secrets.nix.
{
  config,
  pkgs-unstable,
  ...
}:

{
  home.packages = [
    pkgs-unstable.vault
  ];

  programs.zsh.initContent = ''
    vault_login() {
      if ! vault token lookup >/dev/null 2>&1; then
        echo "Vault not logged in - logging in..."
        export VAULT_TOKEN=$(vault login -method=oidc -token-only)
        echo "Token written to VAULT_TOKEN environment variable."
      fi
    }
  '';
}
