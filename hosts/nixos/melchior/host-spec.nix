{ ... }:
{
  hostSpec = {
    hostName = "melchior";
    users = [ "taneb" ];

    # Touchpad identity for kcminputrc. Ids from /proc/bus/input/devices.
    touchpad = {
      vendor = 1739; # 0x06cb
      product = 52542; # 0xcd3e
      name = "SYNA2B31:00 06CB:CD3E Touchpad";
    };
  };
}
