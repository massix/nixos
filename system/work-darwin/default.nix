{ config
, pkgs
, ...
}:
{
  age = {
    identityPaths = [ "/Users/${config.system.primaryUser}/.age/key.txt" ];
    secrets = {
      cloudflare-ca = {
        file = ./secrets/cloudflare-cr.crt.age;
        mode = "0644";
      };

    };
  };

  massix.darwin-common = {
    dark-mode = false;
    iconStyle = "RegularAutomatic";
    tap-to-click = true;
    common-safari-extensions = true;
    dock = {
      tileSize = 48;
      position = "bottom";
      largeSize = 64;
    };
  };

  homebrew = {
    brews = [
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
      # INFO: these are needed because the company's policies keep reinstalling them
      "Pages" = 361309726;
      "Keynote" = 361285480;
      "Numnbers" = 361304891;
    };
  };
  nix.settings.ssl-cert-file = "/etc/ssl/certs/combined-ca-bundle.crt";
  system.activationScripts.postActivation = {
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
}
