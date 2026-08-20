{ config
, pkgs
, ...
}:
{
  age = {
    identityPaths = [ "/Users/mgengarelli/.age/key.txt" ];
    secrets = {
      cloudflare-ca = {
        file = ./secrets/cloudflare-cr.crt.age;
        mode = "0644";
      };

    };
  };
  homebrew = {
    enable = true;
    enableFishIntegration = true;
    onActivation.cleanup = "zap";
    brews = [
      "mas"
      "mlx-lm"
    ];
    casks = [
      "antinote"
      "bitwarden"
      "front"
      "ghostty"
      "macpass"
      "netnewswire"
      "proton-pass"
      "shottr"
      "spotify"
      "whatsapp"
    ];
    masApps = {
      "uBlock Origin Lite" = 6745342698;
      "Ghostery AdBlocker for Privacy" = 6504861501;
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
      ssl-cert-file = "/etc/ssl/certs/combined-ca-bundle.crt";
    };
  };
  system = {
    stateVersion = 7;
    primaryUser = "mgengarelli";
    tools.darwin-rebuild.enable = true;
    activationScripts.postActivation = {
      text = ''
        echo "Merging cacert + WARP root CA..." >&2
        for i in $(seq 1 5); do
          echo "Waiting $i"
          if [ -s "${config.age.secrets.cloudflare-ca.path}" ]; then
            break
          fi
          sleep 1
        done
        if [ ! -s "${config.age.secrets.cloudflare-ca.path}" ]; then
          echo "WARNING: agenix secret not present after 30s, bundle will be incomplete" >&2
        fi
        cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt "${config.age.secrets.cloudflare-ca.path}" > /etc/ssl/certs/combined-ca-bundle.crt
        chmod 644 /etc/ssl/certs/combined-ca-bundle.crt
      '';
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
        AppleIconAppearanceTheme = "ClearAutomatic";
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "WhenScrolling";
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
