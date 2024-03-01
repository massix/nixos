{ pkgs
, unstable
, ...
}:
let
  mkOneDriverService = { pkgs, mountpoint }: {
    Unit = {
      Description = "onedriver";
    };

    Service = {
      ExecStart = "${pkgs.onedriver}/bin/onedriver ${mountpoint}";
      ExecStopPost = "${pkgs.fuse}/bin/fusermount -uz ${mountpoint}";
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
    name = "Rec Mono Casual";
    size = 10;
  };
  hl = {
    enabled = true;
    file = "$HOME/org/.hledger.journal";
  };
in
{
  my-modules = {
    fonts = {
      enable = true;
      configuration.unstable = true;
      families = {
        noto-fonts = true;
        liberation = true;
        fira-code = true;
        nerdfonts = true;
        extra = with unstable; [
          mplus-outline-fonts.githubRelease
          proggyfonts
          monaspace
          meslo-lg
          ibm-plex
          recursive
        ];
      };
    };

    coding = {
      enable = true;
      unstable = true;
      languages = {
        c = true;
        c_sharp = true;
        haskell = true;
        javascript = true;
        java = true;
        json = true;
        lua = true;
        misc = true;
        nix = true;
        purescript = true;
        racket = true;
        rust = true;
        scripting = true;
        terraform = true;
        yaml = true;
      };
    };

    fish = {
      enable = true;
      configuration = {
        unstable = true;
        extraShellAbbrs = {
          j = "just";
          tf = "terraform";
          g = "git";
          mk = "make";
        };
      };
    };

    gaming = {
      enable = true;
      dwarfFortress = {
        enable = true;
        config = {
          theme = with pkgs.dwarf-fortress-packages; themes.ironhand;
        };
      };
    };

    helix = {
      enable = true;
      package = unstable.helix;
      configuration.unstable = true;
      defaultEditor = false;
      configuration.theme = "tokyonight_storm";
    };

    im = {
      enable = true;
      configuration.unstable = true;
    };

    neovim = {
      enable = true;
      configuration.package = unstable.neovim-unwrapped;
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
      configuration.unstable = true;
    };

    zellij = {
      enable = false;
      configuration = {
        autoAttach = false;
        autoExit = false;
        unstable = true;
        enableFishIntegration = true;
      };
    };
  };

  programs = {

    vscode = {
      enable = true;
      mutableExtensionsDir = true;
      package = unstable.vscode-fhs;
    };

    nushell = {
      enable = true;
      package = unstable.nushell;
      configFile.source = ./files/nushell_config.nu;
      envFile.source = ./files/nushell_env.nu;
    };

    firefox = {
      enable = true;
      package = unstable.firefox;
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
        package = unstable.kitty;
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
      package = unstable.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = "compact";
        tweaks = [ ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus";
      package = unstable.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Catppuccin-Mocha-Mauve-Cursors";
      package = unstable.catppuccin-cursors.mochaMauve;
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
      stable-packages = with pkgs; [
        gnome.dconf-editor
        gnome3.gnome-tweaks
      ];

      unstable-packages = with unstable; [
        just
        powertop
        microsoft-edge
        pbpctrl
        gtk-engine-murrine

        # document conversion
        pandoc

        # Only for Teams PWA
        google-chrome

        spotify
        spotube

        gnomeExtensions.gsconnect
        onedriver
        tana
      ];

      other-packages = [ ];

      hledger-packages =
        if hl.enabled then with unstable; [
          hledger
          hledger-ui
          hledger-web
          hledger-utils
        ] else [ ];
    in
    stable-packages ++ unstable-packages ++ other-packages ++ hledger-packages;

  systemd.user.startServices = "sd-switch";

  # Automount Onedriver
  systemd.user.services = {
    "onedriver@home-massi-OneDrive" = mkOneDriverService {
      pkgs = unstable;
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
