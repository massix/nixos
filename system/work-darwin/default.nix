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
  homebrew = {
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
