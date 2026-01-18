{ pkgs
, config
, ...
}:
let
  wrapperDir = "/run/wrappers/";

  mkOnedriverService = { pkgs, mountpoint }: {
    Unit = {
      Description = "onedriver";
    };

    Service = {
      ExecStart = "${pkgs.onedriver}/bin/onedriver ${mountpoint}";
      ExecStopPost = "${wrapperDir}/bin/fusermount3 -uz ${mountpoint}";
      Restart = "on-abnormal";
      RestartSec = "3";
      RestartForceExitStatus = "2";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  terminalFont = {
    name = "IBM Plex Mono";
    size = 10;
  };
in
{
  imports = [ ];

  my-modules = {
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

    gleeter.enable = false;

    fish = {
      enable = true;
      configuration = {
        extraShellAbbrs = {
          j = "just";
          mk = "make";
        };
      };
    };

    gaming = {
      enable = true;
      dwarfFortress = {
        enable = false;
        config = {
          theme = with pkgs.dwarf-fortress-packages; themes.ironhand;
          enableDwarfTherapist = false;
          enableLegendsBrowser = false;
        };
      };
      nethack = {
        enable = true;
        options = {
          permInvent = true;
          petType = "cat";
          msgWindow = "reversed";
          litCorridor = true;
        };
      };
      cataclysm-dda.enable = true;
    };

    im.enable = true;

    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
    };

    git = {
      enable = true;
      workRepository.enabled = false;
    };

    zellij = {
      enable = false;
      configuration = {
        autoAttach = false;
        autoExit = false;
        enableFishIntegration = false;
      };
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

    ghostty =
      let
        add-plus = l: map (x: "+${x}") l;
        to-font-feature = l: builtins.concatStringsSep "," (add-plus l);
      in
      {
        enable = true;
        package = pkgs.ghostty;
        theme = "Catppuccin Macchiato";
        extraSettings = {
          font-family = "Maple Mono";
          font-size = "9";
          font-feature = to-font-feature [
            "calt" # ligatures
            "cv03" # alternative i
            "cv05" # alternative g
            "cv64" # alternative &
            "ss03" # [INFO] and other arbitrary tags
            "ss08" # >>= ligature
            "ss09" # alternative ~=
            "ss10" # alternative =~
            "ss11" # alternative |=
          ];
          window-height = "60";
          window-width = "190";
          background-opacity = "0.9";
        };
        extraPackages = with pkgs; [
          _0xproto
          noto-fonts-color-emoji
          maple-mono.truetype
        ];
      };

    kitty = {
      enable = true;
      font = {
        inherit (terminalFont) name size;
        packages = with pkgs; [ comic-mono _0xproto ];
        italic = "0xProto Italic";
      };
    };

    taskwarrior = {
      enable = true;
      withFish = true;
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
    onedriver
    tana
    protonvpn-gui
    hypnotix
    inkscape-with-extensions
    (transmission_4.override { enableGTK3 = true; })
    libnatpmp
    proton-pass
    unzip
  ];

  systemd.user.startServices = "sd-switch";

  # Automount Onedriver
  systemd.user.services = {
    "onedriver@home-massi-OneDrive" = mkOnedriverService {
      inherit pkgs;
      mountpoint = "\${HOME}/OneDrive";
    };
  };

  xdg = {
    enable = true;
    mime.enable = true;
  };
}
