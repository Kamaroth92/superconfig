{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../users/taneb/default.nix
  ];

  networking.hostName = "melchior";

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # networking
  networking.networkmanager.enable = true;

  # desktop (gnome)
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # printing
  services.printing.enable = true;

  # audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.extraConfig."51-bluez-config" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
          "hfp_hf"
          "hfp_ag"
        ];
      };
    };
  };

  # bluetooth
  hardware.bluetooth.enable = true;

  # gui apps
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vscode
    discord
    steam
    bitwarden-desktop
    vlc
  ];
}
