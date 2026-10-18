# GNOME desktop — the alternative to desktop-plasma.nix. Enable one or the
# other in a host's default.nix; headless hosts like wsl-builder import neither.
{ ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };
}
