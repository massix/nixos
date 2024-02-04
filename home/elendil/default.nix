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
          ibm-plex
          recursive
        ];
      };
    };

    coding = {
      enable = true;
      unstable = true;
      languages = {
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

    kitty = {
      enable = true;
      package = unstable.kitty;
      theme = "Catppuccin-Mocha";

      shellIntegration = {
        mode = "enabled";
        enableFishIntegration = true;
      };

      # -> == <- >>= =<< != >= <=
      font = {
        name = "Rec Mono Casual";
        size = 9;
      };

      settings = {
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

  services.syncthing = {
    enable = true;
    tray.enable = false;
  };

  home.sessionVariables = {
    EMACS = "${unstable.emacs-unstable}/bin/emacs";
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
        just
        powertop
        microsoft-edge
        pbpctrl
        gtk-engine-murrine

        # document conversion
        pandoc

        # pdflatex
        texlive.combined.scheme-small

        # Only for Teams PWA
        google-chrome

        spotify
        spotube

        # TODO: make a module out of this
        emacs-unstable
        emacsPackages.vterm

        gnomeExtensions.gsconnect
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
  };
}
