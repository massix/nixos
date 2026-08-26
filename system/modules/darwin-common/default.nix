{ config
, lib
, ...
}:
{
  options.massix.darwin-common = {
    dock = {
      position = lib.mkOption {
        type = lib.types.enum [ "left" "bottom" "right" ];
        default = "left";
        description = "Dock position on screen.";
      };
      tileSize = lib.mkOption {
        type = lib.types.int;
        default = 58;
        description = "Size (px) of regular dock icons.";
      };
      largeSize = lib.mkOption {
        type = lib.types.int;
        default = 96;
        description = "Magnified size (px) of dock icons on hover.";
      };
    };
    iconStyle = lib.mkOption {
      type = lib.types.str;
      default = "RegularAutomatic";
      description = "Value for NSGlobalDomain.AppleIconAppearanceTheme (icon rendering style).";
    };
    appearance = lib.mkOption {
      type = lib.types.str;
      default = "Dark";
      description = "Value for NSGlobalDomain.AppleInterfaceStyle (light/dark appearance).";
    };
  };

  config = {
    # Package installation (brews/casks/masApps) is deliberately left to the
    # host configs; only the homebrew plumbing lives here.
    homebrew = {
      enable = true;
      enableFishIntegration = true;
      onActivation.cleanup = "zap";
      global.autoUpdate = true;
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
          AppleIconAppearanceTheme = config.massix.darwin-common.iconStyle;
          AppleInterfaceStyle = config.massix.darwin-common.appearance;
          AppleShowAllExtensions = true;
          AppleShowScrollBars = "WhenScrolling";
          NSAutomaticSpellingCorrectionEnabled = false;
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSWindowShouldDragOnGesture = true;
        };
        dock = {
          mouse-over-hilite-stack = true;
          orientation = config.massix.darwin-common.dock.position;
          show-recents = false;
          magnification = true;
          tilesize = config.massix.darwin-common.dock.tileSize;
          largesize = config.massix.darwin-common.dock.largeSize;
        };
      };
    };
  };
}
