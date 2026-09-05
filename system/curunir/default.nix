{ ... }:
{
  networking = let hostname = "curunir"; in {
    computerName = "Curunir";
    hostName = hostname;
    localHostName = hostname;
  };
  homebrew = {
    brews = [
      "mas"
    ];
    casks = [
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
      "whatsapp"
    ];
    masApps = {
      "uBlock Origin Lite" = 6745342698;
      "Proton Pass for Safari" = 6502835663;
    };
  };
  massix.darwin-common.dock = {
    tileSize = 48;
    largeSize = 64;
  };
}
