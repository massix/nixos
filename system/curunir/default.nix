{ ... }:
{
  networking = {
    hostName = "curunir";
    localHostName = "curunir";
  };
  homebrew = {
    enable = true;
    enableFishIntegration = true;
    onActivation.cleanup = "zap";
    brews = [
      "mas"
    ];
    casks = [
      "antinote"
      "cloudflare-warp"
      "ghostty"
      "google-drive"
      "iina"
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
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "mgengarelli" ];
    };
  };
  system = {
    stateVersion = 7;
    primaryUser = "mgengarelli";
    tools.darwin-rebuild.enable = true;
    defaults = {
      finder = {
        ShowStatusBar = true;
        ShowPathbar = true;
        AppleShowAllExtensions = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        NewWindowTarget = "Home";
      };
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      dock = {
        mouse-over-hilite-stack = true;
        orientation = "left";
        show-recents = false;
        magnification = true;
        tilesize = 48;
        largesize = 64;
      };
    };
  };
}
