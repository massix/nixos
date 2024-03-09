{ config
, lib
, modulesPath
, unstable
, ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "i915" ];
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

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
    extraPackages = with unstable; lib.mkDefault [
      intel-media-driver
      vaapiVdpau
      libvdpau-va-gl
      intel-vaapi-driver
    ];
  };

  hardware.bluetooth = with unstable; {
    settings = {
      General = {
        Experimental = true;
        ControllerMode = "dual";
      };
      Policy.AutoEnable = true;
    };
    package = bluez.override { enableExperimental = true; };
  };

  services.auto-cpufreq = {
    enable = true;
    settings =
      let
        governor = "powersave";
        scaling_min_freq = "400000";
        scaling_max_freq.charger = "3900000";
        scaling_max_freq.battery = "3900000";
        turbo.charger = "always";
        turbo.battery = "always";
        options = builtins.map
          (setting: {
            name = setting;
            value = {
              inherit governor scaling_min_freq;

              scaling_max_freq = scaling_max_freq."${setting}";
              turbo = turbo."${setting}";
            };
          }) [ "charger" "battery" ];
      in
      builtins.listToAttrs options;
  };

  services.throttled = {
    enable = true;
    extraConfig = ''
      [GENERAL]
      Enabled: True
      Sysfs_Power_Path: /sys/class/power_supply/ADP*/online
      Autoreload: True

      [BATTERY]
      Update_Rate_s: 20
      PL1_Tdp_W: 12
      PL1_Duration_s: 28
      PL2_Tdp_W: 44
      PL2_Duration_S: 0.002
      Trip_Temp_C: 75
      cTDP: 1
      Disable_BDPROCHOT: True

      [AC]
      Update_Rate_s: 5
      PL1_Tdp_W: 32
      PL1_Duration_s: 28
      PL2_Tdp_W: 44
      PL2_Duration_S: 0.002
      Trip_Temp_C: 80
      HWP_Mode: True
      cTDP: 0
      Disable_BDPROCHOT: True

      [UNDERVOLT.BATTERY]
      CORE: 0
      GPU: 0
      CACHE: 0
      UNCORE: 0
      ANALOGIO: 0

      [UNDERVOLT.AC]
      CORE: 0
      GPU: 0
      CACHE: 0
      UNCORE: 0
      ANALOGIO: 0
    '';
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
    powertop.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
