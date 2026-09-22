{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "melchior";

  # sops file lives next to this host file
  sops.defaultSopsFile = ../../secrets/secrets.yaml;

  # ── Boot ────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── Networking ──────────────────────────────────────────
  networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  # ── Desktop (GNOME) ─────────────────────────────────────
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # ── Printing ────────────────────────────────────────────
  services.printing.enable = true;

  # ── Audio ───────────────────────────────────────────────
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
        "bluez5.enable-sbc-xq"    = true;
        "bluez5.enable-msbc"      = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "hfp_hf" "hfp_ag" ];
      };
    };
  };

  # ── Bluetooth ───────────────────────────────────────────
  hardware.bluetooth.enable = true;

  # ── GUI apps ────────────────────────────────────────────
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vscode
    discord
    steam
    bitwarden-desktop
    vlc
  ];
}
