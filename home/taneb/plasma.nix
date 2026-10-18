# taneb's KDE Plasma preferences (keyboard + touchpad natural scroll).
# Wayland reads these files, not services.xserver; hostSpec.touchpad comes via extraSpecialArgs.
{ lib, hostSpec, ... }:
let
  tp = hostSpec.touchpad;
in
{
  # Keyboard layout au.
  xdg.configFile."kxkbrc".text = ''
    [Layout]
    LayoutList=au
    VariantList=
    Use=true
  '';

  # Natural touchpad scrolling (no-op without hostSpec.touchpad).
  xdg.configFile."kcminputrc" = lib.mkIf (tp != null) {
    text = ''
      [Libinput][${toString tp.vendor}][${toString tp.product}][${tp.name}]
      NaturalScroll=true
    '';
  };
}
