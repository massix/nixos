{ pkgs
, ...
}:
{
  networking = let hostname = "mithrandir"; in {
    computerName = "Mithrandir";
    hostName = hostname;
    localHostName = hostname;
  };

  massix.darwin-common = {
    iconStyle = "RegularAutomatic";
    tap-to-click = true;
    common-safari-extensions = true;

    dock = {
      position = "bottom";
      largeSize = 96;
      tileSize = 48;
    };
  };

  environment.shells = [ pkgs.fish ];
  homebrew = {
    brews = [
      "anomalyco/tap/opencode-v2"
      "mlx-lm"
    ];
    casks = [
      "battle-net"
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
      "spotify"
      "steam"
      "transmission"
      "whatsapp"
    ];
    masApps = {
      "Proton Pass for Safari" = 6502835663;
      "Magic Switch" = 6816653452;
    };
  };
  nix.package = pkgs.lix;
}
