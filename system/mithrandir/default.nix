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
      "mlx-lm"
      "speedtest-go"
    ];
    casks = [
      "crmne/tap/fastpotify"
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
    };
  };
  nix.package = pkgs.lix;
}
