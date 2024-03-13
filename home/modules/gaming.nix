{ pkgs, unstable, config, lib, ... }:
let
  cfg = config.my-modules.gaming;
  inherit (lib) mkEnableOption mkIf mkOption types;
  mkDisableOption = description: mkEnableOption description // { default = true; };
  mkStringOption = description: default: mkOption { type = types.str; inherit default description; };
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
    nethack = {
      enable = mkEnableOption "install Nethack";
      unstable = mkEnableOption "use unstable package";
      options = {
        autoPickup = mkDisableOption "Automatically pickup items";
        pickupTypes = mkStringOption "Pickup types" "$";
        pickupThrown = mkDisableOption "Always pickup thrown objects";
        menuStyle = mkStringOption "Menu style" "full";
        menuColors = mkDisableOption "Menu colors";
        runMode = mkStringOption "Run mode" "crawl";
        permInvent = mkEnableOption "Permanent inventory";
        numberPad = mkStringOption "Number pad" "0";
        petType = mkStringOption "Pet type" "cat";
        msgWindow = mkStringOption "Message window" "single";
        litCorridor = mkEnableOption "Distinguish between lit and unlit corridors";
      };
    };
    dwarfFortress = {
      enable = mkEnableOption "Install Dwarf Fortress";
      unstable = mkEnableOption "Use unstable package";
      config = {
        theme = mkOption {
          description = "Theme to use";
          default = pkgs.dwarf-fortress-packages.themes.obsidian;
        };
        ## The following options are enabled by default
        enableDwarfTherapist = mkDisableOption "Dwarf Therapist";
        enableLegendsBrowser = mkDisableOption "Legends browser";

        ## The following options are disabled by default
        enableIntro = mkEnableOption "Intro";
        enableSoundSense = mkEnableOption "SoundSense";
        enableStoneSense = mkEnableOption "StoneSense";
      };
    };
  };

  config =
    let
      dfChannel = if cfg.dwarfFortress.unstable then unstable else pkgs;
      nhChannel = if cfg.nethack.unstable then unstable else pkgs;
    in
    mkIf cfg.enable {

      home.sessionVariables = mkIf cfg.nethack.enable {
        NETHACKOPTIONS = "@${config.xdg.configHome}/nethack/options";
      };

      xdg.configFile."nethack/options" = mkIf cfg.nethack.enable {
        text =
          let
            boolOpt = name: enabled: if enabled then "${name}" else "!${name}";
          in
          ''
            OPTIONS=${boolOpt "autopickup" cfg.nethack.options.autoPickup}
            OPTIONS=${boolOpt "pickup_thrown" cfg.nethack.options.pickupThrown}
            OPTIONS=${boolOpt "menucolors" cfg.nethack.options.menuColors}
            OPTIONS=${boolOpt "perm_invent" cfg.nethack.options.permInvent}
            OPTIONS=${boolOpt "lit_corridor" cfg.nethack.options.litCorridor}
            OPTIONS=pickup_types:${cfg.nethack.options.pickupTypes}
            OPTIONS=menustyle:${cfg.nethack.options.menuStyle}
            OPTIONS=runmode:${cfg.nethack.options.runMode}
            OPTIONS=number_pad:${cfg.nethack.options.numberPad}
            OPTIONS=pettype:${cfg.nethack.options.petType}
            OPTIONS=msg_window:${cfg.nethack.options.msgWindow}
          '';
      };

      home.packages =
        let
          dwarfFortress =
            if cfg.dwarfFortress.enable then with dfChannel.dwarf-fortress-packages; [
              (dwarf-fortress-full.override {
                inherit (cfg.dwarfFortress.config) theme enableDwarfTherapist enableLegendsBrowser enableIntro enableSoundSense enableStoneSense;
              })
            ] else [ ];
          netHack = if cfg.nethack.enable then (with nhChannel; [ nethack ]) else [ ];
        in
        dwarfFortress ++ netHack;

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
