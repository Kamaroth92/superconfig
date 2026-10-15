# Melchior-only: EasyEffects audio processing, imported only where PipeWire runs.
# Its user unit Requires= pipewire.service, which headless hosts lack.
{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.easyeffects ];

  # Headless so RNNoise loads without the GUI; restores the last-used presets.
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
