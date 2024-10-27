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
      ExecStopPost = "${wrapperDir}/bin/fusermount3 -uz ${mountpoint}";
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

    gleeter.enable = true;

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
        # FIXME: Typst is broken with rust 1.80, re-enable it once the
        # upstream https://github.com/nvarner/typst-lsp/pull/515 will
        # be merged and nixos modules refreshed
        typst = false;
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

    zed = {
      enable = false;
      settings = {
        buffer_font_size = 12;
        buffer_font_family = terminalFont.name;
      };
    };

    kitty = {
      enable = true;
      font = {
        inherit (terminalFont) name size;
        packages = with pkgs; [ comic-mono _0xproto ];
        italic = "0xProto Italic";
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
      show-battery-percentage = true;
      clock-show-date = true;
      clock-show-weekday = true;
      monospace-font-name = "${terminalFont.name} ${builtins.toString terminalFont.size}";
    };

    "org/gnome/desktop/background" = rec {
      picture-uri = "${catppuccin-backgrounds}/wallpapers-main/misc/doggocat.png";
      picture-uri-dark = picture-uri;
      picture-options = "zoom";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      disable-while-typing = true;
      tap-to-click = true;
      tap-and-drag = true;
      two-finger-scrolling-enabled = true;
      accel-profile = "adaptive";
    };

    "org/gnome/shell" = {
      allow-extension-installation = true;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "colosseum@sereneblue"
        "dash-to-dock@micxgx.gmail.com"
        "emoji-copy@felipeftn"
        "fullscreen-avoider@noobsai.github.com"
        "grand-theft-focus@zalckos.github.com"
        "mprisLabel@moon-0xff.github.com"
        "nothing-to-say@extensions.gnome.wouter.bolsterl.ee"
        "peek-top-bar-on-fullscreen@marcinjahn.com"
        "unblank@sun.wxg@gmail.com"
        "upower-battery@codilia.com"
        "quick-settings-avatar@d-go"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "gsconnect@andyholmes.github.io"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    "org/gnome/shell/extensions/auto-move-windows".application-list = [
      "org.telegram.desktop.desktop:3"
      "webcord.desktop:3"
      "com.rtosta.zapzap.desktop:3"
    ];

    "org/gnome/shell/extensions/colosseum" = {
      compact-mode = true;
      fifawc-enabled = true;
      seriea-enabled = true;
      seriea-int = true;
      seriea-roma = true;
      seriea-bol = true;
      uefachampions-enabled = true;
      uefaeuro-enabled = true;
    };
  };

  services.syncthing = {
    enable = false;
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

    onedriver
    tana

    protonvpn-gui

    slack
    hypnotix

    inkscape-with-extensions
    (transmission_4.override { enableGTK3 = true; })
    libnatpmp

    proton-pass
    unzip

    flameshot
  ] ++ (with pkgs.gnomeExtensions; [
    appindicator
    blur-my-shell
    colosseum
    dash-to-dock
    emoji-copy
    fullscreen-avoider
    grand-theft-focus
    media-controls
    nothing-to-say
    peek-top-bar-on-fullscreen
    unblank
    upower-battery
    user-avatar-in-quick-settings
    auto-move-windows
    gsconnect
    removable-drive-menu
    screenshot-window-sizer
    system-monitor
    user-themes
    windownavigator
  ]);

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
