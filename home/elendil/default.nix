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
        ];
      };
    };

    fish = {
      enable = true;
      configuration.unstable = true;
    };

    helix = {
      enable = true;
      package = unstable.helix;
      configuration.unstable = true;
      defaultEditor = false;
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
      shellIntegration.enableFishIntegration = true;

      font = {
        package = unstable.nerdfonts;
        name = "JetBrainsMono Nerd Font";
        size = 11;
      };

      settings = {
        cursor_shape = "beam";
        cursor_beam_thickness = "2.0";
        scrollback_lines = 10000;

        tab_bar_style = "powerline";
        tab_bar_align = "left";

        background_opacity = "0.9";
        dynamic_background_opacity = true;

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
        chromium
        spotify
        just
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

    # Apparently it's a big source of memory leaks...
    # "fx-cast-bridge" = {
    #   Unit.Description = "fx-cast for firefox";
    #   Install.WantedBy = [ "graphical-session.target" ];
    #   Service = {
    #     ExecStart = "${unstable.fx-cast-bridge}/bin/fx_cast_bridge -d";
    #     Restart = "on-abnormal";
    #     RestartSec = "3";
    #     RestartForceExitStatus = "2";
    #   };
    # };
  };

  xdg = {
    enable = true;
    mime.enable = true;
  };
}
