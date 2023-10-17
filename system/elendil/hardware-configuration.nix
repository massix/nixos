{ config
, lib
, modulesPath
, pkgs
, ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e9f57e65-2d06-4fd1-bdfa-e79212b90efa";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4E39-B1D8";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  # Enable DHCP on all interfaces
  networking.useDHCP = lib.mkDefault true;

  # Enable surface-control
  microsoft-surface.surface-control.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  services.throttled.enable = true;

  services.auto-cpufreq = {
    enable = true;
    settings =
      let
        governor = "powersave";
        scaling_min_freq = "400000";
        scaling_max_freq = "2200000";
        turbo = "never";

        options = builtins.map
          (setting: {
            name = setting;
            value = {
              inherit governor turbo scaling_min_freq scaling_max_freq;
            };
          }) [ "charger" "battery" ];
      in
      builtins.listToAttrs options;
  };


  # Cap the CPU between 400MHz 2,2GHz at start, avoid heating
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  powerManagement.cpufreq = {
    max = 2200000;
    min = 400000;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
