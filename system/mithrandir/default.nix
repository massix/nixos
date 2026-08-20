{ pkgs
, ...
}:
{
  networking = let hostname = "mithrandir"; in {
    computerName = "Mithrandir";
    hostName = hostname;
    localHostName = hostname;
  };
  environment.shells = [ pkgs.fish ];
  homebrew = {
    enable = true;
    enableFishIntegration = true;
    onActivation.cleanup = "zap";
    brews = [
      "mas"
      "mlx-lm"
    ];
    casks = [
      "cloudflare-warp"
      "ghostty"
      "google-drive"
      "iina"
      "iptvnator"
      "netnewswire"
      "onedrive"
      "proton-drive"
      "proton-pass"
      "protonvpn"
      "steam"
      "whatsapp"
    ];
    masApps = {
      "Proton Pass for Safari" = 6502835663;
      "uBlock Origin Lite" = 6745342698;
    };
    global = {
      autoUpdate = true;
    };
  };
  programs.fish.enable = true;
  nix = {
    enable = true;
    package = pkgs.lix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "massi" ];
    };
  };
  system = {
    stateVersion = 7;
    primaryUser = "massi";
    tools.darwin-rebuild.enable = true;
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
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        AppleIconAppearanceTheme = "RegularAutomatic";
        NSAutomaticSpellingCorrectionEnabled = false;
        NSWindowShouldDragOnGesture = true;
      };
      dock = {
        mouse-over-hilite-stack = true;
        orientation = "left";
        show-recents = false;
        magnification = true;
        tilesize = 58;
        largesize = 96;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
