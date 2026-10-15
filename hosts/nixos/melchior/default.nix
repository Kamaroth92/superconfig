# Melchior — desktop workstation.
{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    (lib.custom.relativeToRoot "hosts/common/core")
    (lib.custom.relativeToRoot "hosts/common/optional/desktop.nix")
    (lib.custom.relativeToRoot "hosts/common/optional/audio.nix")
    (lib.custom.relativeToRoot "hosts/common/optional/bluetooth.nix")
    (lib.custom.relativeToRoot "hosts/common/optional/printing.nix")
    (lib.custom.relativeToRoot "hosts/common/optional/firefox.nix")
    ./hardware-configuration.nix
    ./host-spec.nix
  ];

  # Boot — required or the system has no loader and won't be bootable.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # USB/IP export side, for forwarding the physical mouse to the Windows host
  # running League of Legends (Riot Vanguard blocks Sunshine's injected mouse).
  boot.kernelModules = [ "usbip-core" "usbip-host" ];

  # usbip listens on TCP 3240 for attach requests from the Windows host.
  networking.firewall.allowedTCPPorts = [ 3240 ];

  networking.networkmanager.enable = true;

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
    htop
    gimp
  ];
}
