{ pkgs
, ...
}:
let
  wrapperDir = "/run/wrappers/";
  inherit (pkgs) lib fetchFromGitHub;

  mOnedriverService = { pkgs, mountpoint }: {
    Unit = {
      Description = "onedriver";
    };

    Service = {
      ExecStart = "${pkgs.onedriver}/bin/onedriver ${mountpoint}";
      ExecStopPost = "${wrapperDir}/bin/fusermount -uz ${mountpoint}";
      Restart = "on-abnormal";
      RestartSec = "3";
      RestartForceExitStatus = "2";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  catppuccin-backgrounds = pkgs.stdenvNoCC.mkDerivation {
    pname = "catppuccin-backgrounds";
    version = "0.0.1";
    nativeBuildInputs = [ pkgs.unzip ];

    src = pkgs.fetchurl {
      url = "https://github.com/Gingeh/wallpapers/archive/refs/heads/main.zip";
      hash = "sha256-I00clrtirzZYPSxGcg5Fkv0vuFHX9uF5UcMv1JZ+7iE=";
    };

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out
      unzip -d $out $src
    '';
  };

  terminalFont = {
    name = "0xProto";
    size = 9;
  };

  hl = {
    enabled = true;
    file = "$HOME/org/.hledger.journal";
  };

  rioThemes = pkgs.stdenvNoCC.mkDerivation {
    pname = "catppuccin-rio-themes";
    version = "0.0.1";

    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "rio";
      rev = "a8d3d3c";
      hash = "sha256-bT789sEDJl3wQh/yfbmjD/J7XNr2ejOd0UsASguyCQo=";
    };

    dontBuild = true;
    dontCheck = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/rio/themes
      cp *.toml $out/rio/themes/
    '';
  };

  warpThemes = pkgs.stdenvNoCC.mkDerivation {
    pname = "catppuccin-warp-themes";
    version = "0.0.1";

    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "warp";
      rev = "5d88d7e";
      hash = "sha256-Q1N9Vwrv+Ub4jprb/Ys8p8GfNs1sN7Q1fLFHVAeH1e0=";
    };

    dontBuild = true;
    dontCheck = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/warp/themes
      cp dist/*.yml $out/warp/themes/
    '';
  };
in
{
  my-modules = {
    fonts = {
      enable = true;
      families = {
        noto-fonts = true;
        liberation = true;
        fira-code = true;
        nerdfonts = true;
        extra = with pkgs; [
          mplus-outline-fonts.githubRelease
          proggyfonts
          monaspace
          meslo-lg
          ibm-plex
          recursive
          _0xproto
          comic-mono
        ];
      };
    };

    coding = {
      enable = true;
      languages = {
        c = false;
        c_sharp = true;
        haskell = false;
        javascript = true;
        java = true;
        json = true;
        kotlin = true;
        lua = true;
        misc = true;
        nix = true;
        purescript = true;
        racket = false;
        rust = true;
        scripting = true;
        terraform = true;
        yaml = true;
        typst = true;
      };
    };

    fish = {
      enable = true;
      configuration = {
        extraShellAbbrs = {
          j = "just";
          tf = "terraform";
          g = "git";
          mk = "make";
          zj = "zellij";
          zjl = "zellij ls";
          zja = "zellij attach";
          zjd = "zellij delete-session";
          zjda = "zellij delete-all-sessions";
          k = "kubectl";
          kg = "kubectl get";
          kgp = "kubectl get pods";
          kgs = "kubectl get svc";
          kk = "k9s";
        };
      };
    };

    gaming = {
      enable = true;
      dwarfFortress = {
        enable = true;
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
    };

    helix = {
      enable = true;
      defaultEditor = false;
      configuration.theme = "tokyonight_storm";
    };

    im.enable = true;

    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
      gui = {
        enable = true;
        font.name = terminalFont.name;
        font.size = terminalFont.size;
      };
    };

    git = {
      enable = true;
      userEmail = "massimo.gengarelli@gmail.com";
    };

    zellij = {
      enable = true;
      configuration = {
        autoAttach = false;
        autoExit = false;
        enableFishIntegration = false;
      };
    };

    devops = {
      enable = true;
      k9s.enable = true;
      azure-cli.enable = true;
    };
  };

  programs = {

    vscode = {
      enable = true;
      mutableExtensionsDir = true;
      package = pkgs.vscode-fhs;
    };

    nushell = {
      enable = true;
      package = pkgs.nushell;
      configFile.source = ./files/nushell_config.nu;
      envFile.source = ./files/nushell_env.nu;
    };

    firefox = {
      enable = true;
      package = pkgs.firefox;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.disable_stdin = true;
        global.strict_env = true;

        whitelist.prefix = let home = "/home/massi"; in [
          "${home}/dev"
          "${home}/Development"
          "${home}/.config/nvim"
          "${home}/.config/nixos"
        ];
      };
    };

    kitty =
      let
        italic_font = "${terminalFont.name} Italic";
        bold_italic_font = "${terminalFont.name} Bold Italic";
        bold_font = "${terminalFont.name} Bold";
      in
      {
        enable = true;
        package = pkgs.kitty;
        theme = "Catppuccin-Mocha";

        shellIntegration = {
          mode = "enabled";
          enableFishIntegration = true;
        };

        # -> == <- >>= =<< != >= <=
        font = {
          inherit (terminalFont) name size;
        };

        settings = {
          inherit italic_font bold_italic_font bold_font;

          cursor_shape = "beam";
          cursor_beam_thickness = "2.0";
          scrollback_lines = 10000;

          tab_bar_style = "powerline";
          tab_bar_align = "left";

          background_opacity = "1";
          dynamic_background_opacity = true;
          enable_audio_bell = false;

          disable_ligatures = "cursor";

          allow_remote_control = true;
          listen_on = "unix:$\{HOME}/.kitty-{kitty_pid}";
        };
      };

    rio = {
      enable = true;
      package = pkgs.rio;
      settings = {
        cursor = "_";
        blinking-cursor = true;
        hide-cursor-when-typing = false;
        renderer = {
          performance = "High";
        };
        fonts = {
          size = terminalFont.size + 6;
          regular = {
            family = terminalFont.name;
            style = "normal";
          };
          extras = [{ family = "Symbols Nerd Font Mono"; }];
        };
      } // builtins.fromTOML (builtins.readFile "${rioThemes}/rio/themes/catppuccin-mocha.toml");
    };

    command-not-found.enable = false;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };

  # FIXME: extensions have been manually installed, modify this part to
  # guarantee that the `user-theme` extension is installed and enabled.
  # This means migrating all the current installed extensions to this
  # system.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Catppuccin-Mocha-Compact-Mauve-Dark";
    };

    "org/gnome/desktop/background" = rec {
      picture-uri = "${catppuccin-backgrounds}/wallpapers-main/minimalistic/catppuccin_triangle.png";
      picture-uri-dark = picture-uri;
      picture-options = "scaled";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "compact";
        tweaks = [ ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Catppuccin-Mocha-Mauve-Cursors";
      package = pkgs.catppuccin-cursors.mochaMauve;
      size = 32;
    };
  };

  services.syncthing = {
    enable = true;
    tray.enable = false;
  };

  home.sessionVariables = {
    LEDGER_FILE = hl.file;
  };

  home.packages =
    let
      unstable-packages = with pkgs; [
        # Only for Teams PWA
        ungoogled-chromium
        flameshot
        just
        powertop
        microsoft-edge
        pbpctrl
        gtk-engine-murrine
        gnome.dconf-editor
        gnome3.gnome-tweaks

        # document conversion
        pandoc

        spotify
        spotube

        gnomeExtensions.gsconnect
        onedriver
        tana

        warp-terminal
        protonvpn-gui

        slack

        todoist
        todoist-electron
      ];

      other-packages = [ ];

      hledger-packages =
        if hl.enabled then with pkgs; [
          hledger
          hledger-ui
          hledger-web
          hledger-utils
        ] else [ ];
    in
    unstable-packages ++ other-packages ++ hledger-packages;

  systemd.user.startServices = "sd-switch";

  # Automount Onedriver
  systemd.user.services = {
    "onedriver@home-massi-OneDrive" = mOnedriverService {
      inherit pkgs;
      mountpoint = "\${HOME}/OneDrive";
    };
  };

  xdg = {
    enable = true;
    mime.enable = true;

    dataFile."warp-terminal/themes".source = "${warpThemes}/warp/themes";

    configFile."flameshot/flameshot.ini".text = lib.generators.toINI { } {
      General = {
        savePath = "/home/massi/Pictures/Screenshots";
      };
    };

    # Patch to allow Kitty to use Monaspace font
    configFile."fontconfig/conf.d/99-monaspace-monospace.conf".text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <!-- https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font -->
      <fontconfig>
        <match target="scan">
          <test name="family"><string>Monaspace Argon Var</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
        <match target="scan">
          <test name="family"><string>Monaspace Argon</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
        <match target="scan">
          <test name="family"><string>Monaspace Krypton Var</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
        <match target="scan">
          <test name="family"><string>Monaspace Krypton</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
        <match target="scan">
          <test name="family"><string>Monaspace Neon Var</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
        <match target="scan">
          <test name="family"><string>Monaspace Neon</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
        <match target="scan">
          <test name="family"><string>Monaspace Radon Var</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
        <match target="scan">
          <test name="family"><string>Monaspace Radon</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
        <match target="scan">
          <test name="family"><string>Monaspace Xenon Var</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
        <match target="scan">
          <test name="family"><string>Monaspace Xenon</string></test>
          <edit name="spacing"><int>100</int></edit>
        </match>
      </fontconfig>
    '';
  };
}
