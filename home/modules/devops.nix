{ unstable, config, ... }:
let
  inherit (unstable) fetchFromGitHub lib;
  inherit (lib) mkEnableOption mkOption mkIf types;
  yamlGenerator = lib.generators.toYAML { };
  iniGenerator = lib.generators.toINI { };

  cfg = config.my-modules.devops;

  k9sThemes = unstable.stdenvNoCC.mkDerivation {
    pname = "catppuccin-k9s-themes";
    version = "0.0.1";

    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "k9s";
      rev = "590a762";
      hash = "sha256-EBDciL3F6xVFXvND+5duT+OiVDWKkFMWbOOSruQ0lus=";
    };

    dontBuild = true;
    dontCheck = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/k9s/skins
      cp dist/*.yaml $out/k9s/skins/
    '';
  };

in
{
  options.my-modules.devops = {
    enable = mkEnableOption "devops module";
    azure-cli = {
      enable = mkEnableOption "Azure CLI";
    };
    k9s = {
      enable = mkEnableOption "k9s";
      aliases = mkOption {
        type = types.attrs;
        description = "Aliases to configure for k9s";
        default = {
          dp = "deployments";
          sec = "v1/secrets";
          jo = "jobs";
          cr = "clusterroles";
          crb = "clusterrolebindings";
          ro = "roles";
          rb = "rolebindings";
          np = "networkpolicies";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      with unstable;
      let
        k9sPackages = if cfg.k9s.enable then [ k9s ] else [ ];
        azCliPackages = if cfg.azure-cli.enable then [ azure-cli ] else [ ];
        miscPackages = [ kubectl kubernetes-helm ];
      in
      k9sPackages ++ azCliPackages ++ miscPackages;

    home.file = {
      ".azure/config" = mkIf cfg.azure-cli.enable {
        text = iniGenerator {
          core = {
            output = "table";
            first_run = true;
            allow_broker = true;
            collect_telemetry = false;
          };
          cloud = {
            name = "AzureCloud";
          };
          extension = {
            use_dynamic_install = "yes_prompt";
            run_after_dynamic_install = true;
          };
          defaults = {
            location = "westeurope";
          };
          clients = {
            show_secrets_warning = true;
          };
        };

      };
    };

    xdg.configFile = {
      "k9s/config.yaml" = mkIf cfg.k9s.enable {
        text = yamlGenerator {
          k9s = {
            liveViewAutoRefresh = true;
            ui = {
              enableMouse = true;
              reactive = true;
              skin = "catppuccin-mocha";
            };
            logger = {
              buffer = 5000;
              sinceSeconds = -1;
            };
          };
        };
      };

      "k9s/skins" = mkIf cfg.k9s.enable { source = "${k9sThemes}/k9s/skins"; };
    };
  };
}
