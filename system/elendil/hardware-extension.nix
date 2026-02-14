{ lib
, modulesPath
, pkgs
, ...
}:
let
  control-prochot = pkgs.writeShellScriptBin "control-prochot" ''
    #!${pkgs.bash}
    export PATH="$PATH:${pkgs.msr-tools}/bin"

    current_value="0x$(rdmsr 0x1FC)"
    disabled="$(printf '0x%x' "$(( current_value & 0xFFFFFFE ))")"
    enabled="$(printf '0x%x' "$(( current_value | 0xF ))")"

    echo "0x1FC current => $current_value"
    echo "0x1FC to disable => $disabled"
    echo "0x1FC to enable => $enabled"

    case "$1" in
      enable)
        wrmsr -a 0x1FC $enabled
        echo "PROCHOT enabled"
        ;;
      disable)
        wrmsr -a 0x1FC $disabled
        echo "PROCHOT disabled"
        ;;
      *)
        echo "Unknown command $1"
        exit 255
        ;;
    esac
  '';
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = [ control-prochot ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ "i915" "msr" ];
      systemd.enable = true;
      verbose = false;
    };

    kernelModules = [ "kvm-intel" "i915" ];
    kernelPackages = lib.mkForce (pkgs.linuxPackagesFor pkgs.custom-kernel);
    consoleLogLevel = 0;
    supportedFilesystems = [ "ntfs" ];
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "intel_pstate=active"
      "processor.max_cstate=1"
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

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 18 * 1024;
  }];

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
      enable = true;
      settings = {
        General = {
          Experimental = true;
          ControllerMode = "dual";
        };
        Policy.AutoEnable = true;
      };
      package = bluez.override { enableExperimental = true; };
    };
  };

  systemd.services.disable-prochot = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''
        ${lib.getExe control-prochot} disable
      '';
    };
  };

  services.thermald = {
    enable = false;
    configFile = ./files/thermal-conf.xml;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "performance";
    powertop.enable = false;
    cpufreq.min = 800000;
  };
}
