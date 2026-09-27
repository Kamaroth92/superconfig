{
  config,
  pkgs,
  ...
}:

{
  home.stateVersion = "26.05";
  home.file."repos/.keep".text = "";

  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    secrets."deepseek-api-key" = {
      sopsFile = ../../secrets/taneb.yaml;
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets."deepseek-api-key".path})"
    '';
  };

  programs.zsh = {
    enable = true;
    initContent = ''
      export ANTHROPIC_AUTH_TOKEN="$(cat ${config.sops.secrets."deepseek-api-key".path})"
    '';
  };

  # ── Packages ───────────────────────────────────────────
  home.packages = with pkgs; [
    claude-code
  ];

  # ── Git ────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings.user = {
      name = "Tane Barriball";
      email = "tane.barriball@gmail.com";
    };
  };

  # ── rbw ────────────────────────────────────────────────
  programs.rbw = {
    enable = true;
    settings = {
      email = "tanebarriball@gmail.com";
      lock_timeout = 3600;
      pinentry = pkgs.pinentry-curses;
    };
  };
}
