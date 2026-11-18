{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.massix.fish;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    concatMapStrings
    ;
in
{
  options.massix.fish = {
    enable = mkEnableOption "Enable fish handling";

    configuration.extraPaths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra paths to add to fish";
      example = [ "{$HOME}/bin" ];
    };

    configuration.extraInit = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra init options for fish";
      example = [
        "source ~/file"
        "echo 'Hello World'"
      ];
    };
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      package = pkgs.fish;

      shellAbbrs = config.massix.cli-tools.abbreviations;

      plugins =
        let
          fromRepo = plugin: {
            inherit (pkgs.fishPlugins."${plugin}") src;
            name = plugin;
          };
        in
        map fromRepo [
          "grc"
          "z"
          "tide"
          "foreign-env"
          "colored-man-pages"
          "puffer"
          "humantime-fish"
        ];

      shellAliases = config.massix.cli-tools.aliases;

      interactiveShellInit = ''
        set fish_greeting
        ${builtins.concatStringsSep "\n" cfg.configuration.extraInit}

        ${builtins.concatStringsSep "\n" (
          map (sf: ''
            if test -f ${sf.file}
              set -gx ${sf.name} (cat ${sf.file})
            end
          '') config.massix.cli-tools.environment.secretFiles
        )}
      '';

      shellInit = ''
        set -g fish_key_bindings fish_default_key_bindings
      '';
    };

    # Fish integration for the shared tools (provided by cli-tools).
    programs.fzf.enableFishIntegration = true;
    programs.broot.enableFishIntegration = true;

    # Brew integration (Linux) and extra paths.
    xdg.configFile = {
      "fish/conf.d/extra-001-brew.fish".text = ''
        if type -q /home/linuxbrew/.linuxbrew/bin/brew
          eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
        end
      '';

      "fish/conf.d/extra-999-extra-paths.fish".text = ''
        # Extra Paths
        ${concatMapStrings (x: "fish_add_path " + x + "\n") (
          cfg.configuration.extraPaths ++ config.massix.cli-tools.extraPaths
        )}
      '';
    };
  };
}
