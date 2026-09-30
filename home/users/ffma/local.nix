# Local user config — gitignored. Put envs, functions, and secrets here.
{ ... }:

{
  home.sessionVariables = {
    VAULT_ADDR = "https://vault.eng.ffma.cloud/";
    VAULT_NAMESPACE = "ffma";
    AWS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    DBX_ACCOUNT_HOST = "https://accounts.cloud.databricks.com";
    DBX_ACCOUNT_ID = "5549e2c5-2405-4f0c-a022-4554e3a4812a";
  };

  programs.zsh.shellAliases = {
    k = "kubectl";
    kctx = "kubectx";
    kns = "kubens";
  };

  programs.zsh.initContent = ''
    declare -A DBX_WORKSPACES=(
      [platformops]="https://ffma-platformops.cloud.databricks.com"
      [platformops-dev]="https://ffma-platformops-dev.cloud.databricks.com"
      [inv-dev]="https://ffma-inv-dev.cloud.databricks.com"
      [inv-test]="https://ffma-inv-test.cloud.databricks.com"
      [inv-uat]="https://ffma-inv-uat.cloud.databricks.com"
      [inv]="https://ffma-inv.cloud.databricks.com"
      [inv-sandpit]="https://ffma-inv-sandpit.cloud.databricks.com"
      [noninv-dev]="https://ffma-noninv-dev.cloud.databricks.com"
      [noninv-test]="https://ffma-noninv-test.cloud.databricks.com"
      [noninv-uat]="https://ffma-noninv-uat.cloud.databricks.com"
      [noninv]="https://ffma-noninv.cloud.databricks.com"
      [research]="https://futurefund-research.cloud.databricks.com"
    )

    vault_login() {
      if ! vault token lookup >/dev/null 2>&1; then
        echo "Vault not logged in - logging in..."
        vault login -method=oidc
      fi
    }

    awsprofiles() { aws configure list-profiles; }
    awslogin() { export AWS_PROFILE="$1"; aws sso login; }
    awslogout() {
      unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
      aws sso logout
    }
    get-branch() { git symbolic-ref --short HEAD; }

    dbx-auth-account() {
      if databricks auth describe --profile account &>/dev/null; then
        echo "Already authenticated to account level (profile: account)"
        return 0
      fi
      databricks auth login --host "$DBX_ACCOUNT_HOST" --account-id "$DBX_ACCOUNT_ID" --profile account
    }

    dbx-auth-workspace() {
      local workspace=$1
      if [[ -z $workspace ]]; then
        echo "Usage: dbx-auth-workspace <workspace-name>"
        echo "Available: ''${(@k)DBX_WORKSPACES}"
        return 1
      fi
      local host="''${DBX_WORKSPACES[$workspace]}"
      if [[ -z $host ]]; then
        echo "Unknown workspace: $workspace"
        return 1
      fi
      if databricks auth describe --profile "$workspace" &>/dev/null; then
        echo "Already authenticated (profile: $workspace)"
        export DATABRICKS_CONFIG_PROFILE=$workspace
        return 0
      fi
      databricks auth login --host "$host" --profile "$workspace" && export DATABRICKS_CONFIG_PROFILE=$workspace
    }

    dbx-list-workspaces() {
      for ws in "''${(@k)DBX_WORKSPACES}"; do
        echo "  $ws  ''${DBX_WORKSPACES[$ws]}"
      done
    }

    psql-env() {
      local target_env="''${1:-}"
      if [[ -z $target_env ]]; then
        echo "Usage: psql-env <prod|nonprod>"
        return 1
      fi
      vault_login
      case "$target_env" in
        nonprod)
          export PGHOST='aurora-nonprod.nonprod.ffma.cloud'
          export PGPORT='5432'
          export PGDATABASE='postgres'
          export PGUSER='postgres'
          export PGSSLMODE='require'
          export PGPASSWORD=$(vault kv get -mount=devops-platforms -field=PASSWORD aurora/nonprod)
          ;;
        prod)
          export PGHOST='aurora.eng.ffma.cloud'
          export PGPORT='5432'
          export PGDATABASE='postgres'
          export PGUSER='postgres'
          export PGSSLMODE='require'
          export PGPASSWORD=$(vault kv get -mount=devops-platforms -field=PASSWORD aurora/prod)
          ;;
        *)
          echo "Invalid environment: $target_env. Use 'prod' or 'nonprod'."
          return 1
          ;;
      esac
      export PGSERVICE="$target_env"
      echo "Loaded psql environment '$target_env'"
    }
  '';
}
