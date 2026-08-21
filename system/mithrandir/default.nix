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
      "uBlock Origin Lite" = 6745342698;
      "Proton Pass for Safari" = 6502835663;
    };
  };
  nix.package = pkgs.lix;
}
