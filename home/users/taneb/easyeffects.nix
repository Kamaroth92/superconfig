# Melchior-only: imported conditionally on the host having PipeWire (see
# nixos/users/taneb/default.nix), so headless hosts like wsl-builder never try
# to start EasyEffects against a pipewire.service that does not exist.
{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    easyeffects
  ];

  # Run EasyEffects headless so the RNNoise filter is always loaded on login,
  # without needing the GUI open. It restores the last-used input/output
  # presets, so configure them once in the GUI and they persist from here on.
  systemd.user.services.easyeffects = {
    Unit = {
      Description = "EasyEffects audio effects";
      After = [ "wireplumber.service" ];
      Requires = [ "pipewire.service" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.easyeffects} --gapplication-service";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
