{ pkgs, ... }:
let
  catppuccin-backgrounds = pkgs.stdenvNoCC.mkDerivation {
    pname = "catppuccin-backgrounds";
    version = "2024-11-07";
    nativeBuildInputs = [ pkgs.unzip ];

    src = pkgs.fetchurl {
      url = "https://github.com/VipinVIP/wallpapers/archive/refs/heads/main.zip";
      hash = "sha256-9v5VZc0nZf7N12HUKaY78DQKbjadyM6NcD3EWYFpqY4=";
    };

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out
      unzip -d $out $src
    '';
  };
in
{
  home.packages = with pkgs.gnomeExtensions; [
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
    paperwm
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      accent-color = "slate";
      clock-show-date = true;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      cursor-theme = "Adwaita";
      enable-animations = true;
      enable-hot-corners = true;
      font-name = "Adwaita Sans 11";
      icon-theme = "Adwaita";
      monospace-font-name = "IBM Plex Mono 10";
      show-battery-percentage = false;
    };

    "org/gnome/desktop/background" = rec {
      picture-uri = "${catppuccin-backgrounds}/wallpapers-main/misc/feet-on-the-dashboard.png";
      picture-uri-dark = picture-uri;
      picture-options = "zoom";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      disable-while-typing = true;
      tap-to-click = true;
      tap-and-drag = false;
      two-finger-scrolling-enabled = true;
      accel-profile = "default";
      click-method = "fingers";
      speed = 0.45;
    };

    "org/gnome/shell" = {
      allow-extension-installation = true;
      enabled-extensions = [
        "paperwm@paperwm.github.com"
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
      "org.telegram.desktop.desktop:2"
      "webcord.desktop:2"
      "com.rtosta.zapzap.desktop:2"
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

    "org/gnome/shell/extensions/paperwm" = {
      use-default-background = true;
      show-window-position-bar = true;
      winprops =
        let
          boolToString = bool: if bool then "true" else "false";
          mkWinProp = class: title: scratch: ''{"wm_class": "${class}", "title": "${title}", "scratch_layer": ${boolToString scratch}}'';
        in
        [
          (mkWinProp "" "Calculator" true)
          (mkWinProp "" "Extension" true)
          (mkWinProp "gnome-tweaks" "" true)
          (mkWinProp "org.gnome.Extensions" "" true)
          (mkWinProp "" "Picture in picture" true)
          (mkWinProp ".protonvpn-app-wrapped" "" true)
        ];
    };

    "org/gnome/shell/extensions/paperwm/keybindings" = {
      close-window = [ "<Super>q" ];
    };

    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
      dynamic-workspaces = true;
      attach-modal-dialogs = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:close";
      audible-bell = false;
      auto-raise = false;
      resize-with-right-button = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      maximize = [ ];
      minimize = [ ];
      switch-to-workspace-left = [ "<Super><Alt>Left" ];
      switch-to-workspace-right = [ "<Super><Alt>Right" ];
      move-to-workspace-left = [ "<Shift><Super>Left" ];
      move-to-workspace-right = [ "<Shift><Super>Right" ];
      toggle-fullscreen = [ "<Super><Alt>f" ];
    };
  };
}
