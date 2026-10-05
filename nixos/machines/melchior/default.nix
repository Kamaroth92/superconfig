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
  # USB/IP export side, for forwarding the physical mouse to the Windows host
  # running League of Legends (Riot Vanguard blocks Sunshine's injected mouse).
  boot.kernelModules = [ "usbip-core" "usbip-host" ];

  # usbip listens on TCP 3240 for attach requests from the Windows host.
  networking.firewall.allowedTCPPorts = [ 3240 ];

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
    moonlight-qt
    # Matches boot.kernelPackages so the usbip userspace tools line up with the
    # kernel's usbip modules. Provides usbip + usbipd.
    linuxPackages_latest.usbip
  ];
}
