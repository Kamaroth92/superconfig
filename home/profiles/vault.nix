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
        vault login -method=oidc
      fi
    }
  '';
}
