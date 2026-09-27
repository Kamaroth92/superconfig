{
  config,
  lib,
  pkgs,
  ...
}:

let
  rbwConfig = pkgs.writeText "rbw-config.json" (
    builtins.toJSON {
      email = "tanebarriball@gmail.com";
      lock_timeout = 3600;
      pinentry = lib.getExe pkgs.pinentry-curses;
    }
  );
in

{
  # ── Per-user packages ──────────────────────────────────
  users.users.taneb.packages = with pkgs; [
    claude-code
    pinentry-curses
  ];

  # ── Environment variables ──────────────────────────────
  environment.sessionVariables = {
    ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic";
    ANTHROPIC_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash";
    CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-flash";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
    NH_FLAKE = "${config.users.users.taneb.home}/config";

    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket";
  };

  # ── Shell init ─────────────────────────────────────────
  programs.bash = {
    enable = true;
    interactiveShellInit = ''
      export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.deepseek-api-key.path})"
    '';
  };

  programs.zsh.interactiveShellInit = ''
    export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets.deepseek-api-key.path})"
  '';

  # ── Git ────────────────────────────────────────────────
  programs.git = {
    enable = true;
    config.user = {
      name = "Tane Barriball";
      email = "tane.barriball@gmail.com";
    };
  };

  # ── rbw ────────────────────────────────────────────────
  system.activationScripts.rbwConfig = {
    deps = [ "users" ];
    text = ''
      install -d -m 0755 -o taneb -g users ${config.users.users.taneb.home}/.config
      install -d -m 0700 -o taneb -g users ${config.users.users.taneb.home}/.config/rbw
      ln -sfn ${rbwConfig} ${config.users.users.taneb.home}/.config/rbw/config.json
    '';
  };
}
