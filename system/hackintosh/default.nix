{ ... }:
{
  networking = {
    hostName = "hackintosh";
    localHostName = "hackintosh";
  };
  homebrew = {
    enable = true;
    enableFishIntegration = true;
    onActivation.cleanup = "zap";
    brews = [
      "mas"
    ];
    casks = [
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
    global = {
      autoUpdate = true;
    };
  };
  programs.fish.enable = true;
  nix = {
    enable = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "mgengarelli" "root" ];
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
