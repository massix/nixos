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
    common-safari-extensions = true;
    dock = {
      position = "bottom";
      tileSize = 48;
    };
  };

  system.keyboard.swapLeftCommandAndLeftAlt = true;

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
    brews = [ "speedtest-go" ];
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
      "steam"
      "transmission"
      "whatsapp"
    ];
    masApps = {
      "Proton Pass for Safari" = 6502835663;
    };
  };
}
