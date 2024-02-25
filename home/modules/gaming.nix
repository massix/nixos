{ pkgs, unstable, config, lib, ... }:
let
  cfg = config.my-modules.gaming;
  inherit (lib) mkEnableOption mkIf mkOption;
  mkDisableOption = description: mkEnableOption description // { default = false; };
  dfIcon = pkgs.stdenvNoCC.mkDerivation {
    pname = "dficon";
    version = "1.0.0";
    src = pkgs.fetchurl {
      url = "https://upload.wikimedia.org/wikipedia/commons/a/a9/Dwarf_Fortress_Icon.svg";
      hash = "sha256-bnNCf7CuiwlnsEdcBEwbqm5d/1z2xgxmGRdBC9sevmE=";
    };

    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out
      install -m0644 $src $out/dwarf-fortress.svg
    '';
  };
in
{
  options.my-modules.gaming = {
    enable = mkEnableOption "Enable gaming module";
    dwarfFortress = {
      enable = mkEnableOption "Install Dwarf Fortress";
      unstable = mkEnableOption "Use unstable package";
      config = {
        theme = mkOption {
          description = "Theme to use";
          default = pkgs.dwarf-fortress-packages.themes.obsidian;
        };
        ## The following options are enabled by default
        enableDwarfTherapist = mkEnableOption "Dwarf Therapist";
        enableLegendsBrowser = mkEnableOption "Legends browser";

        ## The following options are disabled by default
        enableIntro = mkDisableOption "Intro";
        enableSoundSense = mkDisableOption "SoundSense";
        enableStoneSense = mkDisableOption "StoneSense";
      };
    };
  };

  config =
    let
      dfChannel = if cfg.dwarfFortress.unstable then unstable else pkgs;
    in
    mkIf cfg.enable {
      home.packages =
        let
          dwarfFortress =
            if cfg.dwarfFortress.enable then with dfChannel.dwarf-fortress-packages; [
              (dwarf-fortress-full.override {
                inherit (cfg.dwarfFortress.config) theme enableDwarfTherapist enableLegendsBrowser enableIntro enableSoundSense enableStoneSense;
              })
            ] else [ ];
        in
        dwarfFortress;

      xdg.desktopEntries."dwarf-fortress" = mkIf cfg.dwarfFortress.enable {
        name = "Dwarf Fortress";
        exec = "dwarf-fortress";
        type = "Application";
        icon = "${dfIcon}/dwarf-fortress.svg";
        terminal = false;
        categories = [ "Game" ];
      };
    };
}
