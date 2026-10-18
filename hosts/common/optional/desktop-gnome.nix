# GNOME desktop. One desktop-*.nix per host; headless hosts import none.
{ ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };
}
