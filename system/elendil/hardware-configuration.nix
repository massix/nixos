{ config
, lib
, modulesPath
, pkgs
, ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "i915" ];
      systemd.enable = true;
      verbose = false;
    };

    kernelModules = [ "kvm-intel" "i915" ];
    extraModulePackages = [ ];
    blacklistedKernelModules = [ "int3403_thermal" ];
    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor pkgs.custom-kernel);
    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    loader.timeout = 0;

    plymouth = {
      enable = true;
      theme = "glitch";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "glitch" ];
        })
      ];
    };
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
      size = 18 * 1024;
    }
  ];

  # Enable DHCP on all interfaces
  networking.useDHCP = lib.mkDefault true;

  hardware = {
    enableAllFirmware = true;

    sane = {
      enable = true;
      extraBackends = with pkgs; [ hplipWithPlugin sane-airscan ];
    };

    # Enable OpenGL
    graphics = {
      enable = true;

      # Force newer versions of GL packages
      extraPackages = with pkgs; lib.mkDefault [
        intel-media-driver
        vaapiVdpau
        libvdpau-va-gl
        intel-vaapi-driver
      ];
    };

    bluetooth = with pkgs; {
      settings = {
        General = {
          Experimental = true;
          ControllerMode = "dual";
        };
        Policy.AutoEnable = true;
      };
      package = bluez.override { enableExperimental = true; };
    };

    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  services.thermald = {
    enable = true;
    configFile = ./files/thermal-conf.xml;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave";
    powertop.enable = false;
    cpufreq.min = 800000;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
