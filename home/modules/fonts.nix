{ config, pkgs, lib, ... }:
let
  cfg = config.my-modules.fonts;
  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  options.my-modules.fonts = {
    enable = mkEnableOption "Enable fonts handling";
    typefonts = mkEnableOption "install typeface fonts" // { default = true; };
    monospace = mkEnableOption "install monospace fonts" // { default = true; };

    families.extra = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Extra fonts to be installed";
      example = [ "pkgs.proggyfonts" ];
    };
  };

  config =
    let
      orEmpty = cond: fonts: if cond then fonts else [ ];
      monospace-fonts =
        orEmpty cfg.monospace (with pkgs; [
          liberation_ttf
          fira-code
          fira-code-symbols
          nerdfonts
        ]);
      typeface-fonts =
        orEmpty cfg.typefonts (with pkgs; [
          open-sans
          libertine
          google-fonts
          noto-fonts
          noto-fonts-cjk
          noto-fonts-emoji
        ]);
    in
    mkIf cfg.enable {
      fonts.fontconfig.enable = true;
      home.packages = monospace-fonts ++ typeface-fonts ++ cfg.families.extra;
    };
}
