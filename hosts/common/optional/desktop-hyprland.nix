# Hyprland tiling compositor. One desktop-*.nix per host; headless hosts import none.
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;

    # withSystemd=false: the bundled uwsm-managed session hangs on this host.
    package = pkgs.hyprland.override { withSystemd = false; };
  };

  # SDDM's greeter needs X11 (Hyprland doesn't enable it implicitly).
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };
}
