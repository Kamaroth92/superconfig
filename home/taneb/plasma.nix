# taneb's KDE Plasma preferences, shared across every host where taneb runs
# Plasma. Import this on a host alongside desktop-plasma.nix; headless hosts
# skip it.
#
# Plasma's Wayland session reads keyboard layout and input-device settings from
# KDE config files, not from NixOS's services.xserver options (those only drive
# SDDM and the X11 fallback). Hardware identities (hostSpec.touchpad) are
# machine-level facts passed down via extraSpecialArgs; the preferences below
# are the user layer that consumes them.
{ lib, hostSpec, ... }:
let
  tp = hostSpec.touchpad;
in
{
  # Keyboard layout "au", matching desktop-plasma.nix's services.xserver.xkb.
  xdg.configFile."kxkbrc".text = ''
    [Layout]
    LayoutList=au
    VariantList=
    Use=true
  '';

  # Natural (inverted) touchpad scrolling, keyed to this host's touchpad. A
  # no-op on hosts that don't define hostSpec.touchpad.
  xdg.configFile."kcminputrc" = lib.mkIf (tp != null) {
    text = ''
      [Libinput][${toString tp.vendor}][${toString tp.product}][${tp.name}]
      NaturalScroll=true
    '';
  };
}
