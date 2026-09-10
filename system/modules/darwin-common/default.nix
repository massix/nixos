{ config
, lib
, ...
}:
let
  inherit (lib) types;
  cfg = config.massix.darwin-common;
in
{
  options.massix.darwin-common = {
    dock = {
      position = lib.mkOption {
        type = types.enum [ "left" "bottom" "right" ];
        default = "left";
        description = "Dock position on screen.";
      };
      tileSize = lib.mkOption {
        type = types.int;
        default = 58;
        description = "Size (px) of regular dock icons.";
      };
      largeSize = lib.mkOption {
        type = types.int;
        default = 96;
        description = "Magnified size (px) of dock icons on hover.";
      };
    };
    iconStyle = lib.mkOption {
      type = types.str;
      default = "RegularAutomatic";
      description = "Value for NSGlobalDomain.AppleIconAppearanceTheme (icon rendering style).";
    };
    dark-mode = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Enable Dark mode";
    };
    tap-to-click = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Enable the Tap to Click option on the Trackpad";
    };
    common-safari-extensions = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Install the common extensions for Safari from the Mac App Store";
    };
  };

  config = {
    # Package installation (brews/casks/masApps) is deliberately left to the
    # host configs; only the homebrew plumbing lives here.
    homebrew = {
      enable = true;
      enableFishIntegration = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        upgrade = true;
      };

      brews = lib.mkIf cfg.common-safari-extensions [
        "mas"
      ];

      masApps = lib.mkIf cfg.common-safari-extensions {
        "uBlock Origin Lite" = 6745342698;
        "PiPifier" = 1160374471;
        "Ghostery AdBlocker for Privacy" = 6504861501;
      };
    };

    programs.fish.enable = true;

    nix = {
      enable = true;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ config.system.primaryUser ];
      };
    };

    system = {
      tools.darwin-rebuild.enable = true;
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
      defaults = {
        hitoolbox.AppleFnUsageType = "Change Input Source";
        iCal = {
          "first day of week" = "Monday";
          CalendarSidebarShown = true;
        };
        magicmouse.MouseButtonMode = "TwoButton";
        controlcenter = {
          BatteryShowPercentage = false;
          Sound = false;
          FocusModes = false;
          NowPlaying = true;
        };
        finder = {
          AppleShowAllExtensions = true;
          FXPreferredViewStyle = "clmv";
          FXRemoveOldTrashItems = true;
          NewWindowTarget = "Home";
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowPathbar = true;
          ShowRemovableMediaOnDesktop = true;
          ShowStatusBar = true;
          _FXEnableColumnAutoSizing = true;
          _FXSortFoldersFirst = true;
        };
        NSGlobalDomain = {
          AppleIconAppearanceTheme = cfg.iconStyle;
          AppleInterfaceStyle = if cfg.dark-mode then "Dark" else null;
          AppleShowAllExtensions = true;
          AppleShowScrollBars = "WhenScrolling";
          NSAutomaticSpellingCorrectionEnabled = false;
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSWindowShouldDragOnGesture = true;
        };
        trackpad.Clicking = cfg.tap-to-click;
        dock = {
          mouse-over-hilite-stack = true;
          orientation = cfg.dock.position;
          show-recents = false;
          magnification = true;
          tilesize = cfg.dock.tileSize;
          largesize = cfg.dock.largeSize;
        };
      };
    };
  };
}
