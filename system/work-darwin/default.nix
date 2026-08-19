{ config
, pkgs
, ...
}:
let
  combinedCaBundle = pkgs.runCommand "combined-ca-bundle.crt" { } ''
    cat ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt ${config.age.secrets.cloudflare-ca.path} > $out
  '';
in
{
  age = {
    identityPaths = [ "/Users/mgengarelli/.age/key.txt" ];
    # FIXME: this is kind of a horrible hack and counter-intuitive, but to enable copying this, you
    # must first remove the ${combinedCaBundle} reference from the nix configuration, then re-enable this
    # then you can safely re-enable the nix configuration. This might be a bug in nix-darwin but it's not
    # worth investigating yet.
    secrets = {
      cloudflare-ca = {
        file = ./secrets/cloudflare-cr.crt.age;
        mode = "0644";
        path = "/etc/ssl/cloudflare-cr.crt";
      };

    };
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
      "bitwarden"
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
      ssl-cert-file = "${combinedCaBundle}";
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
  };
}
