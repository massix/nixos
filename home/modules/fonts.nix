{ config, pkgs, unstable, lib, ... }:
let
  cfg = config.my-modules.fonts;
  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  options.my-modules.fonts = {
    enable = mkEnableOption "Enable fonts handling";
    configuration.unstable = mkEnableOption "Install from the unstable channel";
    families.noto-fonts = mkEnableOption "Install noto-fonts";
    families.liberation = mkEnableOption "Install Liberation fonts";
    families.fira-code = mkEnableOption "Install fira-code";
    families.nerdfonts = mkEnableOption "Install NerdFonts";

    families.extra = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Extra fonts to be installed";
      example = [ "proggyfonts" ];
    };
  };

  config =
    let
      stable_font_list = with pkgs;
        (if cfg.families.noto-fonts then [
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
        ] else [ ]) ++
        (if cfg.families.liberation then [
          liberation_ttf
        ] else [ ]) ++
        (if cfg.families.fira-code then [
          fira-code
          fira-code-symbols
        ] else [ ]) ++
        (if cfg.families.nerdfonts then [
          nerdfonts
        ] else [ ]);

      unstable_font_list = with unstable;
        (if cfg.families.noto-fonts then [
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
        ] else [ ]) ++
        (if cfg.families.liberation then [
          liberation_ttf
        ] else [ ]) ++
        (if cfg.families.fira-code then [
          fira-code
          fira-code-symbols
        ] else [ ]) ++
        (if cfg.families.nerdfonts then [
          nerdfonts
        ] else [ ]);
    in
    mkIf cfg.enable {
      fonts.fontconfig.enable = true;
      home.packages = (if cfg.configuration.unstable then unstable_font_list else stable_font_list) ++ cfg.families.extra;
    };
}
