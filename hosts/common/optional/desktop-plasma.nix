# KDE Plasma desktop. One desktop-*.nix per host; headless hosts import none.
{ ... }:
{
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };
}
