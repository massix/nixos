{ pkgs
, lib
, ...
}:
{
  networking = let hostname = "curunir"; in {
    computerName = "Curunir";
    hostName = hostname;
    localHostName = hostname;
  };

  massix.darwin-common = {
    iconStyle = "RegularAutomatic";
    tap-to-click = false;
    dark-mode = false;
    common-safari-extensions = true;
    dock = {
      position = "bottom";
      tileSize = 48;
    };
  };

  system.keyboard.swapLeftCommandAndLeftAlt = true;
  nix.package = pkgs.lix;

  system.defaults = {
    WindowManager.AppWindowGroupingBehavior = false;
    WindowManager.EnableTopTilingByEdgeDrag = false;
    controlcenter.BatteryShowPercentage = lib.mkForce true;
    loginwindow.LoginwindowText = "Courtesy of OpenCore";
    dock = {
      enable-spring-load-actions-on-all-items = true;
      wvous-tl-corner = 2;
      wvous-tr-corner = 3;
    };
  };

  services.openssh = {
    enable = true;
    extraConfig = ''
      # Keep only Public Key Authentication
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      ChallengeResponseAuthentication no
      PubkeyAuthentication yes

      # Allow using symlinks in authorized_keys
      StrictModes no
    '';
  };

  homebrew = {
    brews = [
      "anomalyco/tap/opencode-v2"
    ];
    casks = [
      "crmne/tap/spotifast"
      "ghostty"
      "google-drive"
      "iina"
      "iptvnator"
      "netnewswire"
      "onedrive"
      "proton-drive"
      "proton-mail"
      "proton-pass"
      "protonvpn"
      "shottr"
      "steam"
      "transmission"
      "whatsapp"
    ];
    masApps = {
      "Proton Pass for Safari" = 6502835663;
    };
  };
}
