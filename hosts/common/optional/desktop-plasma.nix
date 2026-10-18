# KDE Plasma desktop — the alternative to desktop-gnome.nix. Enable one or
# the other in a host's default.nix; headless hosts like wsl-builder import
# neither.
{ ... }:
{
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };
}
