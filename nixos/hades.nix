{ config, pkgs, ... }:

{
  boot = {
    initrd.availableKernelModules   = [
      "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"
    ];
    initrd.kernelModules            = [ "amdgpu" ];
    kernelPackages                  = pkgs.linuxPackages_latest;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable      = true;
  };

  environment.systemPackages = with pkgs; [ dropbox-cli ];

  fileSystems = {
    "/".device     = "/dev/disk/by-label/nixos";
    "/".fsType     = "xfs";
    "/boot".device = "/dev/disk/by-uuid/9E04-A8F9";
    "/boot".fsType = "vfat";
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.extraPackages      = with pkgs; [ libvdpau-va-gl vaapiVdpau ];

  home-manager.users.jupblb = import ../home.nix;

  imports = [ <home-manager/nixos> ./common.nix ];

  networking.hostName              = "hades";
  networking.networkmanager.enable = true;

  nix.maxJobs = 12;

  services = {
    apcupsd.enable     = true;
    apcupsd.configText = ''
      UPSCABLE usb
      UPSTYPE usb
      DEVICE
    '';

    fstrim.enable = true;

    wakeonlan.interfaces = [ {
      interface = "eno2";
      method    = "magicpacket";
    } ];
  };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  system.stateVersion = "20.03";

  systemd.services.dropbox = {
    after                        = [ "network.target" ];
    description                  = "Dropbox";
    environment.QML2_IMPORT_PATH = with pkgs.qt5; ''
      ${qtbase}${qtbase.qtQmlPrefix}
    '';
    environment.QT_PLUGIN_PATH   = with pkgs.qt5; ''
      ${qtbase}${qtbase.qtPluginPrefix}
    '';
    serviceConfig                = {
      ExecStart     = "${pkgs.dropbox}/bin/dropbox";
      ExecReload    = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      KillMode      = "control-group";
      Nice          = 10;
      PrivateTmp    = true;
      ProtectSystem = "full";
      Restart       = "on-failure";
      User          = "jupblb";
    };
    wantedBy                     = [ "default.target" ];
  };

  time.hardwareClockInLocalTime = true;
}
