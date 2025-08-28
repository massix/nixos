{ pkgs, ... }:
let
  version = "${kernelVersion}-zen1";
  kernelBaseVersion = "6.15";
  kernelVersion = "6.15.3";
  inherit (pkgs) lib fetchFromGitHub;

  linuxSurface = fetchFromGitHub {
    repo = "linux-surface";
    owner = "linux-surface";
    rev = "arch-${kernelVersion}-2";
    hash = "sha256-7rUierGzAW4WlzEcPz+a0G8fDwR14u2BJgA+mvUeDKg=";
  };

  linuxZen = fetchFromGitHub {
    repo = "zen-kernel";
    owner = "zen-kernel";
    rev = "v${kernelVersion}-zen1";
    hash = "sha256-0s9tdC0K+e7RCsfPhlB6kroXDq0n9B12RUYrBdX+e7w=";
  };

  getPatch = name: {
    inherit name;
    patch = "${linuxSurface}/patches/${kernelBaseVersion}/${name}.patch";
  };
in
pkgs.buildLinux {
  pname = "linux-${kernelVersion}-surface-zen";
  version = kernelVersion;
  modDirVersion = version;

  src = linuxZen;
  ignoreConfigErrors = true;

  structuredExtraConfig = with lib.kernel; {
    # Zen Interactive tuning
    ZEN_INTERACTIVE = yes;

    # FQ-Codel Packet Scheduling
    NET_SCH_DEFAULT = yes;
    DEFAULT_FQ_CODEL = yes;

    # Preempt (low-latency)
    PREEMPT = lib.mkOverride 60 yes;
    PREEMPT_VOLUNTARY = lib.mkOverride 60 no;

    # Preemptible tree-based hierarchical RCU
    TREE_RCU = yes;
    PREEMPT_RCU = yes;
    RCU_EXPERT = yes;
    TREE_SRCU = yes;
    TASKS_RCU_GENERIC = yes;
    TASKS_RCU = yes;
    TASKS_RUDE_RCU = yes;
    TASKS_TRACE_RCU = yes;
    RCU_STALL_COMMON = yes;
    RCU_NEED_SEGCBLIST = yes;
    RCU_FANOUT = freeform "64";
    RCU_FANOUT_LEAF = freeform "16";
    RCU_BOOST = yes;
    RCU_BOOST_DELAY = option (freeform "500");
    RCU_NOCB_CPU = yes;
    RCU_LAZY = yes;
    RCU_DOUBLE_CHECK_CB_TIME = yes;

    # BFQ I/O scheduler
    IOSCHED_BFQ = lib.mkOverride 60 yes;

    # Futex WAIT_MULTIPLE implementation for Wine / Proton Fsync.
    FUTEX = yes;
    FUTEX_PI = yes;

    # NT synchronization primitive emulation
    NTSYNC = yes;

    # Preemptive Full Tickless Kernel at 1000Hz
    HZ = freeform "1000";
    HZ_1000 = yes;

    # Alternative zpool for zswap
    Z3FOLD = yes;

    # Specific stuff for Surface
    STAGING_MEDIA = yes;

    ##
    ## Surface Aggregator Module
    ##
    SURFACE_AGGREGATOR = module;
    # SURFACE_AGGREGATOR_ERROR_INJECTION is not set
    SURFACE_AGGREGATOR_BUS = yes;
    SURFACE_AGGREGATOR_CDEV = module;
    SURFACE_AGGREGATOR_HUB = module;
    SURFACE_AGGREGATOR_REGISTRY = module;
    SURFACE_AGGREGATOR_TABLET_SWITCH = module;

    SURFACE_ACPI_NOTIFY = module;
    SURFACE_DTX = module;
    SURFACE_PLATFORM_PROFILE = module;

    SURFACE_HID = module;
    SURFACE_KBD = module;

    BATTERY_SURFACE = module;
    CHARGER_SURFACE = module;

    SENSORS_SURFACE_TEMP = module;
    SENSORS_SURFACE_FAN = module;

    ##
    ## Surface Hotplug
    ##
    SURFACE_HOTPLUG = module;

    ##
    ## IPTS and ITHC touchscreen
    ##
    ## This only enables the user interface for IPTS/ITHC data.
    ## For the touchscreen to work, you need to install iptsd.
    ##
    HID_IPTS = module;
    HID_ITHC = module;

    ##
    ## Cameras: IPU3
    ##
    VIDEO_DW9719 = module;
    VIDEO_IPU3_IMGU = module;
    VIDEO_IPU3_CIO2 = module;
    IPU_BRIDGE = module;
    INTEL_SKL_INT3472 = module;
    REGULATOR_TPS68470 = module;
    COMMON_CLK_TPS68470 = module;
    LEDS_TPS68470 = module;

    ##
    ## Cameras: Sensor drivers
    ##
    VIDEO_OV5693 = module;
    VIDEO_OV7251 = module;
    VIDEO_OV8865 = module;

    ##
    ## Surface 3: atomisp causes problems (see issue #1095). Disable it for now.
    ##
    # INTEL_ATOMISP is not set

    ##
    ## ALS Sensor for Surface Book 3, Surface Laptop 3, Surface Pro 7
    ##
    APDS9960 = module;

    ##
    ## Build-in UFS support (required for some Surface Go devices)
    ##
    SCSI_UFSHCD = module;
    SCSI_UFSHCD_PCI = module;

    ##
    ## Other Drivers
    ##
    INPUT_SOC_BUTTON_ARRAY = module;
    SURFACE_3_POWER_OPREGION = module;
    SURFACE_PRO3_BUTTON = module;
    SURFACE_GPE = module;
    SURFACE_BOOK1_DGPU_SWITCH = module;
  };

  kernelPatches = builtins.map getPatch [
    "0001-secureboot"
    "0002-surface3"
    "0003-mwifiex"
    "0004-ath10k"
    "0005-ipts"
    "0006-ithc"
    "0007-surface-sam"
    "0008-surface-sam-over-hid"
    "0009-surface-button"
    "0010-surface-typecover"
    "0011-surface-shutdown"
    "0012-surface-gpe"
    "0013-cameras"
    "0014-amd-gpio"
    "0015-rtc"
  ];
}
