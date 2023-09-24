{ pkgs
, unstable
, ...
}:
let
  mypkgs = import ../../pkgs { inherit pkgs; };
  inherit (mypkgs) onedriver;
in
{
  my-modules.fonts = {
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

  my-modules.fish.enable = true;
  my-modules.fish.configuration.unstable = true;

  my-modules.helix.enable = true;
  my-modules.helix.package = unstable.helix;
  my-modules.helix.configuration.unstable = true;

  my-modules.im.enable = true;
  my-modules.im.configuration.unstable = true;

  my-modules.git = {
    enable = true;
    userEmail = "massimo.gengarelli@gmail.com";
    configuration.unstable = true;
  };

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
    package = unstable.vscode-fhs;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = false;
  };

  programs.nushell = {
    enable = true;
    package = unstable.nushell;
    configFile.source = ./files/nushell_config.nu;
    envFile.source = ./files/nushell_env.nu;
  };

  programs.firefox = {
    enable = true;
    package = unstable.firefox-wayland;
  };

  programs.kitty = {
    enable = true;
    package = unstable.kitty;
    theme = "One Half Dark";
    shellIntegration.enableFishIntegration = true;

    font = {
      package = unstable.nerdfonts;
      name = "Iosevka NerdFont";
      size = 11;
    };

    settings = {
      cursor_shape = "beam";
      cursor_beam_thickness = "2.0";
      scrollback_lines = 10000;

      tab_bar_style = "powerline";
      tab_bar_align = "left";

      background_opacity = "0.8";
      dynamic_background_opacity = true;
    };
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
        fx-cast-bridge
        chromium
        chezmoi
        gnomeExtensions.pop-shell
        spotify
      ];

      other-packages = [
        onedriver.onedriver
      ];
    in
    stable-packages ++ unstable-packages ++ other-packages;

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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
