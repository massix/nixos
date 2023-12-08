{ pkgs
, unstable
, ...
}:
let
  mypkgs = import ../../pkgs { inherit pkgs; };
  inherit (mypkgs) onedriver;
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
        ];
      };
    };

    fish = {
      enable = true;
      configuration = {
        unstable = true;
        extraShellAbbrs = {
          j = "just";
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
      configuration.unstable = true;
      defaultEditor = true;
      languages = {
        java = true;
        auto = true;
      };
    };

    git = {
      enable = true;
      userEmail = "massimo.gengarelli@gmail.com";
      configuration.unstable = true;
    };

    zellij = {
      enable = true;
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

    kitty = {
      enable = true;
      package = unstable.kitty;
      theme = "Tokyo Night Storm";

      shellIntegration = {
        mode = "enabled";
        enableFishIntegration = true;
      };

      # -> == <- >>= =<< != >= <=
      font = {
        name = "Monaspace Neon";
        size = 10;
      };

      settings = {
        italic_font = "Monaspace Radon";
        bold_italic_font = "Monaspace Radon";
        bold_font = "Monaspace Neon";

        cursor_shape = "beam";
        cursor_beam_thickness = "2.0";
        scrollback_lines = 10000;

        tab_bar_style = "powerline";
        tab_bar_align = "left";

        background_opacity = "0.9";
        dynamic_background_opacity = true;
        enable_audio_bell = false;

        disable_ligatures = "cursor";
      };
    };

    command-not-found.enable = false;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };

  services.syncthing = {
    enable = true;
    tray.enable = false;
  };

  home.packages =
    let
      stable-packages = with pkgs; [
        gnome.dconf-editor
        gnome3.gnome-tweaks
        rclone
      ];

      unstable-packages = with unstable; [
        obsidian
        spotify
        just
        powertop
        microsoft-edge
        pbpctrl

        # Only for Teams PWA
        google-chrome
        libsForQt5.kdenlive
      ];

      other-packages = [
        onedriver.onedriver
      ];
    in
    stable-packages ++ unstable-packages ++ other-packages;

  systemd.user.startServices = "sd-switch";

  # Automount Onedriver
  systemd.user.services = {
    "onedriver@home-massi-OneDrive" = onedriver.mkOneDriverService {
      mountpoint = "\${HOME}/OneDrive";
      inherit (onedriver) onedriver;
      inherit (pkgs) fuse;
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

    /* desktopEntries =
      let
        chromeFlags = "--enable-features=VaapiVideoEncoder,VaapiVideoDecoder,TouchpadOverscrollHistoryNavigation,UseOzonePlatform --ozone-platform=wayland --disable-video-capture-use-gpu-memory-buffer --enable-native-gpu-memory-buffers --use-gl=angle --use-angle=gl";
        chromeBin = "${unstable.google-chrome}/bin/google-chrome-stable";
      in
      {
        ## Google Chrome fix for Wayland and Gnome 44
        google-chrome-fixed = {
          name = "Google Chrome Fixed";
          genericName = "Web Browser";
          exec = "${chromeBin} ${chromeFlags}";
          type = "Application";
          icon = "google-chrome";
          startupNotify = true;
          terminal = false;
          categories = [ "Application" "Network" "WebBrowser" ];
          mimeType = [ "text/html" "text/xml" ];
        };

        ## PWA for Microsoft Teams
        microsoft-teams = {
          name = "Microsoft Teams Fixed";
          genericName = "Communication";
          exec = "${chromeBin} ${chromeFlags} --app-id=cifhbcnohmdccbgoicgdjpfamggdegmo --profile-directory=Default";
          icon = "chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Default";
          terminal = false;
        };
      }; */
  };
}
