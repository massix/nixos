{ ... }:
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
  };
  homebrew = {
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
      "Proton Pass for Safari" = 6502835663;
    };
  };
  massix.darwin-common.dock = {
    tileSize = 48;
    largeSize = 64;
  };
}
