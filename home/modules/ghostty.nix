{ lib
, pkgs
, config
, ...
}:
let
  cfg = config.massix.ghostty;
  inherit (lib) types mkOption mkIf mkEnableOption;
  # Default values which are valid on both MacOS and GNU/Linux
  # (MacOS options are simply ignored when on GNU/Linux)
  settings = {
    alpha-blending = "native";
    # we are using nix to update
    auto-update = "off";
    background-blur = "true";
    background-opacity = "0.8";
    cursor-click-to-move = "true";
    cursor-style = "block";
    cursor-style-blink = "true";
    macos-icon = "glass";
    macos-option-as-alt = "true";
    macos-titlebar-style = "native";
    mouse-hide-while-typing = "true";
    quick-terminal-animation-duration = "0.6";
    quick-terminal-autohide = "true";
    quick-terminal-position = "bottom";
    quick-terminal-screen = "mouse";
    quick-terminal-space-behavior = "move";
    resize-overlay = "always";
    resize-overlay-position = "top-right";
    # equivalent to cursor,sudo,title
    shell-integration-features = "true";
    unfocused-split-opacity = "0.7";
    window-inherit-font-size = "false";
    window-inherit-working-directory = "true";
    window-new-tab-position = "current";
    window-subtitle = "false";
  };
  keybindings = {
    "global:cmd+\\" = "toggle_quick_terminal";
    "global:alt+\\" = "toggle_quick_terminal";
  };
in
{
  options.massix.ghostty = {
    enable = mkEnableOption "enable ghostty";
    package = mkOption {
      type = types.package;
      default = pkgs.ghostty;
      description = "Ghostty package to use";
    };
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Extra packages to install (for example, fonts and themes)";
    };
    extraSettings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Settings for ghostty";
    };
    theme = mkOption {
      type = types.str;
      default = "catppuccin-macchiato";
      description = "Theme to use";
    };
    extraKeybindings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Keybindings to set, refer to https://ghostty.org/docs/config/keybind/reference for the actions";
      example = {
        "global:cmd+grave_accent" = "toggle_quick_terminal";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package pkgs.nerd-fonts.symbols-only ] ++ cfg.extraPackages;
    xdg.configFile."ghostty/config" =
      let
        allSettings = settings // cfg.extraSettings // { inherit (cfg) theme; };
        allKeybindings = keybindings // cfg.extraKeybindings;
        allSettingsStr = map (pair: "${pair.name} = ${pair.value}") (lib.attrsToList allSettings);
        allKeybindingsStr = map (pair: "keybind = ${pair.name}=${pair.value}") (lib.attrsToList allKeybindings);
        text = builtins.concatStringsSep "\n" (allSettingsStr ++ allKeybindingsStr);
      in
      {
        inherit text;
      };
  };
}
