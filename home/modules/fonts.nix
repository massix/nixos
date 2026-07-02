{ config, pkgs, lib, ... }:
let
  cfg = config.massix.fonts;
  inherit (lib) mkEnableOption mkIf mkOption types;
  nerdfonts-symbols = pkgs.stdenvNoCC.mkDerivation {
    pname = "symbolsonly-nerdfont";
    version = "3.2.1";
    src = builtins.fetchurl {
      url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/NerdFontsSymbolsOnly.zip";
      sha256 = "sha256:0rixy2sgmv492ja6g9c27ypdav63wpyp5qzr5wkac8nhfkmc4ndw";
    };

    nativeBuildInputs = with pkgs; [ unzip ];

    unpackPhase = ''
      runHook preUnpackHook
      mkdir -p $out/share/fonts/truetype/
      unzip -d $out/share/fonts/truetype $src
      runHook postUnpackHook
    '';

    dontConfigure = true;
    dontBuild = true;
    dontInstall = true;
  };
in
{
  options.massix.fonts = {
    enable = mkEnableOption "Enable fonts handling";
    typefonts = mkEnableOption "install typeface fonts" // { default = true; };
    monospace = mkEnableOption "install monospace fonts" // { default = true; };
    nerdfonts = mkEnableOption "install nerdfonts";

    families.extra = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Extra fonts to be installed";
      example = [ "pkgs.proggyfonts" ];
    };

    families.exclude = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Fonts to exclude from the installed set (per-host opt-outs)";
      example = [ "pkgs.noto-fonts-color-emoji" ];
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
          nerdfonts-symbols
        ]);
      typeface-fonts =
        orEmpty cfg.typefonts (with pkgs; [
          open-sans
          libertine
          google-fonts
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
        ]);
      default-fonts = [ ];
      nerd-fonts = orEmpty cfg.nerdfonts (with pkgs; [ nerdfonts ]);
    in
    mkIf cfg.enable {
      fonts.fontconfig.enable = true;
      home.packages = lib.subtractLists cfg.families.exclude
        (default-fonts ++ nerd-fonts ++ monospace-fonts ++ typeface-fonts ++ cfg.families.extra);
    };
}
