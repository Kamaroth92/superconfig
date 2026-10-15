# GNOME desktop (headless hosts like wsl-builder skip it).
{ ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };
}
