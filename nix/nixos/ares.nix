{ config, pkgs, ... }:

let
  sway'' = pkgs.unstable.sway'.override { withExtraPackages = true };
in {
  imports = [ ./common.nix ];

  boot.initrd.availableKernelModules   = [
    "ahci"
    "ehci_pci"
    "sd_mod" "sr_mod"
    "ums_realtek" "usb_storage" "usbhid"
    "xhci_pci"
  ];
  boot.kernelPackages                  = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable      = true;

  environment.systemPackages = [ sway'' ];

  fileSystems = {
    "/".device     = "/dev/disk/by-label/nixos";
    "/".fsType     = "xfs";
    "/boot".device = "/dev/disk/by-label/boot";
    "/boot".fsType = "vfat";
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.extraPackages      = with pkgs; [
    intel-media-driver libvdpau-va-gl vaapiIntel' vaapiVdpau
  ];

  networking.hostName              = "ares";
  networking.networkmanager.enable = true;

  nix.maxJobs = 8;

  services.fstrim.enable   = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="d8:50:e6:03:5c:44", NAME="eth"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="70:18:8b:3f:58:47", NAME="wlp"
  '';

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  system.stateVersion = "19.09";
}