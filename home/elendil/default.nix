{ pkgs
, config
, lib
, ...
}:
{
  imports = [ ];

  massix = {
    firefox = {
      enable = true;
      enableGnomeExtensions = true;
      extraExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
        proton-pass
      ];
    };
    fonts = {
      enable = true;
      typefonts = false;
      families = {
        extra = with pkgs; [
          monaspace
          ibm-plex
          recursive
          _0xproto
          comic-mono
        ];
      };
    };

    fish = {
      enable = true;
      configuration = {
        extraShellAbbrs = {
          j = "just";
          mk = "make";
        };
      };
    };

    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
    };

    git = {
      enable = true;
      workRepository.enabled = false;
    };

    devops = {
      enable = false;
      k9s.enable = true;
      kubernetes = {
        enable = true;
        colored = true;
      };
      terraform = {
        enable = true;
        flavour = "terraform";
      };
      azure-cli = {
        enable = false;
        extensions = with pkgs.azure-cli-extensions; [ k8s-extension ];
      };
    };

    ghostty = {
      enable = true;
      package = pkgs.ghostty;
      theme = "TokyoNight";
      extraSettings = {
        font-family = "IBM Plex Mono";
        font-size = "9";
        window-height = "60";
        window-width = "190";
        background-opacity = "0.9";
      };
      extraPackages = with pkgs; [
        _0xproto
        noto-fonts-color-emoji
        maple-mono.truetype
        ibm-plex
      ];
    };

    opencode = {
      enable = true;
      mcps = [ "github" "context7" "gh-grep" "coros" ];
      theme = "tokyonight";
    };
    claude-code = {
      enable = true;
      mcps = [ "github" "context7" "gh-grep" "coros" "strava" ];
    };
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.disable_stdin = true;
        global.strict_env = true;

        whitelist.prefix = [
          "${config.home.homeDirectory}/dev"
          "${config.home.homeDirectory}/Development"
          "${config.home.homeDirectory}/.config/nvim"
          "${config.home.homeDirectory}/.config/nixos"
        ];
      };
    };

    command-not-found.enable = false;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
      };
    };
  };

  services = {
    protrans = {
      enable = true;
      configuration.nat.portLifeTime = 60;
    };
  };

  home.sessionVariables = { };

  home.packages = with pkgs; [
    just
    powertop
    pbpctrl
    dconf-editor
    gnome-tweaks
    spotify
    tana
    proton-vpn
    hypnotix
    inkscape-with-extensions
    (transmission_4.override { enableGTK = true; })
    libnatpmp
    proton-pass
    unzip
    zapzap
    telegram-desktop
    haruna
  ];

  systemd.user.startServices = "sd-switch";
  systemd.user.services =
    let
      mkRclone =
        { source
        , dest
        , cacheMode
        , cacheSize
        , cacheAge
        , extraOpts ? [ ]
        }: {
          Unit.Description = "Mount ${source} to ${dest} using rclone";
          Service =
            let
              opts = lib.join " " extraOpts;
            in
            {
              ExecStart = "${lib.getExe pkgs.rclone} mount ${source}: ${dest} --vfs-cache-mode ${cacheMode} --vfs-cache-max-size ${cacheSize} --vfs-cache-max-age ${cacheAge} ${opts}";
              ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${dest}";
              Type = "notify";
              Restart = "on-failure";
            };
          Install.WantedBy = [ "default.target" ];
        };
    in
    {
      rclone-onedrive = mkRclone {
        source = "OneDrivePersonal";
        dest = "${config.home.homeDirectory}/OneDrive";
        cacheMode = "full";
        cacheSize = "4G";
        cacheAge = "3d";
      };

      rclone-proton = mkRclone {
        source = "proton";
        dest = "${config.home.homeDirectory}/ProtonDrive";
        cacheMode = "writes";
        cacheSize = "2G";
        cacheAge = "1h";
        extraOpts = [ "--protondrive-replace-existing-draft=true" ];
      };

      rclone-gdrive = mkRclone {
        source = "gdrive";
        dest = "${config.home.homeDirectory}/GoogleDrive";
        cacheMode = "off";
        cacheSize = "100M";
        cacheAge = "1h";
      };
    };

  xdg = {
    enable = true;
    mime.enable = true;
  };
}
