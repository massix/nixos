{ pkgs
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

  terminalFont = rec {
    name = "Comic Mono";
    italic = "0xProto Italic";
    bold = "${name} Bold";
    size = 12;
  };

  uiFont = {
    name = "Roboto";
    size = 11;
    package = pkgs.roboto;
  };
in
{
  my-modules = {
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

    coding = {
      enable = true;
      languages = {
        c = false;
        c_sharp = true;
        gleam = true;
        go = true;
        haskell = false;
        javascript = true;
        java = true;
        json = true;
        kotlin = false;
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
    };

    im.enable = true;

    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
      gui = {
        enable = true;
        font = {
          inherit (terminalFont) name size;
          features = [
            { name = "Recursive Mn Csl St"; features = [ "+liga" "+dlig" "+ss10" "+ss20" ]; }
          ];
        };
      };
    };

    git = {
      enable = true;
      workRepository = {
        enabled = true;
        workRoot = "~/Development/Work/";
        workEmail = "massimo.gengarelli@alten.com";
      };
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
      azure-cli = {
        enable = true;
        extensions = with pkgs.azure-cli-extensions; [ k8s-extension ];
      };
    };

    zed = {
      enable = false;
      settings = {
        buffer_font_size = 12;
        buffer_font_family = terminalFont.name;
      };
    };
  };

  programs = {
    google-chrome = {
      enable = true;
      package = pkgs.google-chrome;
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
        fontFeatures = ffs: builtins.concatStringsSep "\n" (builtins.map (ff: "font_features ${ff}") ffs);
      in
      {
        enable = true;
        package = pkgs.kitty;
        theme = "Catppuccin-Macchiato";

        shellIntegration = {
          mode = "enabled";
          enableFishIntegration = true;
        };

        font = {
          inherit (terminalFont) name size;
        };

        settings = {
          italic_font = terminalFont.italic;
          bold_font = terminalFont.bold;

          cursor_shape = "beam";
          cursor_beam_thickness = "2.0";
          scrollback_lines = 10000;

          tab_bar_style = "powerline";
          tab_bar_align = "left";

          background_opacity = "0.9";
          dynamic_background_opacity = true;
          enable_audio_bell = false;

          disable_ligatures = "cursor";

          allow_remote_control = true;
          listen_on = "unix:$\{HOME}/.kitty-{kitty_pid}";

          # UI Tweaks
          hide_window_decorations = false;
          draw_minimal_borders = false;
          inactive_text_alpha = "0.6";
          remember_window_size = true;

          window_margin_width = "2";
          single_window_margin_width = "2";
          window_padding_width = "2";
          single_window_padding_width = "2";
          window_border_width = "1";
        };
        extraConfig = builtins.concatStringsSep "\n" [
          (fontFeatures (builtins.map (style: "RecursiveMonoCslSt-${style} +liga +dlig +ss10 +ss20") [ "Regular" "Italic" "Bold" "BdItalic" "Med" ]))
          (fontFeatures (builtins.map (style: "0xProto${style} +ss01") [ "Regular" "Italic" ]))
          (fontFeatures (builtins.map (style: "MonaspaceNeon-${style} +liga +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +ss09 +cv61") [ "Regular" "Italic" "Bold" ]))
          "symbol_map U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d4,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b1,U+e700-U+e7c5,U+f000-U+f2e0,U+f300-U+f372,U+f400-U+f532,U+f0001-U+f1af0 Symbols Nerd Font Mono"
        ];
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
      enable-hot-corners = true;
      show-battery-percentage = true;
      clock-show-date = true;
      document-font-name = "${uiFont.name} ${builtins.toString uiFont.size}";
      monospace-font-name = "${terminalFont.name} ${builtins.toString terminalFont.size}";
      font-hinting = "slight";
      font-antialiasing = "grayscale";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "catppuccin-macchiato-mauve-compact";
    };

    "org/gnome/desktop/background" = rec {
      picture-uri = "${catppuccin-backgrounds}/wallpapers-main/misc/doggocat.png";
      picture-uri-dark = picture-uri;
      picture-options = "zoom";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      disable-while-typing = true;
      tap-to-click = false;
      tap-and-drag = true;
      two-finger-scrolling-enabled = true;
      accel-profile = "adaptive";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-macchiato-mauve-compact";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "compact";
        tweaks = [ ];
        variant = "macchiato";
      };
    };
    iconTheme = {
      name = "Pop";
      package = pkgs.pop-icon-theme;
    };
    cursorTheme = {
      name = "catppuccin-macchiato-mauve-cursors";
      package = pkgs.catppuccin-cursors.macchiatoMauve;
      size = 32;
    };
    font = uiFont;
  };

  services.syncthing = {
    enable = true;
    tray.enable = false;
  };

  services.protrans = {
    enable = true;
    configuration.nat.portLifeTime = 60;
  };

  home.sessionVariables = { };

  home.packages = with pkgs; [
    # Only for Teams PWA
    just
    powertop
    (microsoft-edge.override { commandLineArgs = "--ozone-platform=wayland --force-dark-mode"; })
    pbpctrl
    dconf-editor
    gnome-tweaks

    spotify
    spotube

    gnomeExtensions.gsconnect
    onedriver
    tana

    protonvpn-gui

    slack
    hypnotix

    todoist
    todoist-electron

    inkscape-with-extensions
    (transmission_4.override { enableGTK3 = true; })
    libnatpmp

    obsidian
    proton-pass
    unzip

    flameshot
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
