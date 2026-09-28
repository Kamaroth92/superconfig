{
  config,
  pkgs,
  ...
}:

{
  imports = [ ./shell.nix ];

  # ── User ────────────────────────────────────────────────
  users.users."taneb" = {
    isNormalUser = true;
    description = "taneb";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPPE+hjAIQBKvf3GxYrcX4ImpbPPz17ZdCpL4C8a3Hif taneb-user-key"
    ];
    shell = pkgs.zsh;
  };

  # ── home-manager ───────────────────────────────────────
  home-manager.users."taneb".imports = [ ./home.nix ];

  # ── sops (user secrets) ────────────────────────────────
  # sops.secrets.deepseek-api-key = {
  #   owner = config.users.users.taneb.name;
  #   sopsFile = ../../secrets/taneb.yaml;
  # };

  # ── Environment variables ──────────────────────────────
  environment.sessionVariables = {
    # ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_BASE_URL = "https://openrouter.ai/api";
    ANTHROPIC_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
    ANTHROPIC_API_KEY = "";
    CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-flash";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
    NH_FLAKE = "${config.users.users.taneb.home}/config";

    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
  };

  # ── Shell init ─────────────────────────────────────────

}
