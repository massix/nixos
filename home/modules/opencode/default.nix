{ config, lib, pkgs, ... }:
let
  cfg = config.my-modules.opencode;
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types;

  availableAgents = [ "nixos" "devops" ];

  availableSkills = [ "nix-eval" "nix-debug" "nixfmt" "kubectl" "flux" ];

  agentSkills = {
    nixos = [ "nix-eval" "nix-debug" "nixfmt" ];
    devops = [ "kubectl" "flux" ];
  };

  effectiveSkills =
    builtins.foldl' (acc: agent: acc ++ (agentSkills.${agent} or [ ])) [ ] cfg.agents
    ++ cfg.skills;
in
{
  options.my-modules.opencode = {
    enable = mkEnableOption "Enable opencode configuration";

    package = mkPackageOption pkgs "opencode" {
      default = "opencode";
    };

    mcps = mkOption {
      type = types.listOf (types.enum [ "github" "gh-grep" "context7" ]);
      default = [ ];
      description = "MCP servers to enable";
      example = [ "github" "context7" ];
    };

    theme = mkOption {
      type = types.str;
      default = "";
      description = "UI theme (empty string uses system default)";
    };

    defaultAgent = mkOption {
      type = types.str;
      default = "plan";
      description = "Default agent to use";
    };

    agents = mkOption {
      type = types.listOf (types.enum availableAgents);
      default = [ ];
      description = "Custom agents to enable";
      example = [ "nixos" ];
    };

    skills = mkOption {
      type = types.listOf (types.enum availableSkills);
      default = [ ];
      description = "Skills to enable";
      example = [ "nix-eval" "nix-debug" ];
    };
  };

  config = mkIf cfg.enable (
    let
      skillConfigs = builtins.listToAttrs (
        map
          (skill: {
            name = "opencode/skills/${skill}/SKILL.md";
            value = { source = ./skills/${skill}/SKILL.md; };
          })
          (builtins.filter (s: builtins.elem s effectiveSkills) availableSkills)
      );
    in
    {
      home.packages = [ cfg.package ];

      xdg.configFile = {
        "opencode/opencode.json" = {
          text = builtins.toJSON {
            inherit (cfg) theme;
            default_agent = cfg.defaultAgent;
            mcp = {
              github = {
                type = "remote";
                url = "https://api.githubcopilot.com/mcp/";
                oauth = false;
                headers = {
                  Authorization = "Bearer {env:GH_MCP_TOKEN}";
                };
                enabled = builtins.elem "github" cfg.mcps;
              };
              gh-grep = {
                type = "remote";
                url = "https://mcp.grep.app";
                enabled = builtins.elem "gh-grep" cfg.mcps;
              };
              context7 = {
                type = "remote";
                url = "https://mcp.context7.com/mcp";
                enabled = builtins.elem "context7" cfg.mcps;
              };
            };
          };
        };

        "opencode/agents/nixos.md" = mkIf (builtins.elem "nixos" cfg.agents) {
          source = ./agents/nixos.md;
        };

        "opencode/agents/devops.md" = mkIf (builtins.elem "devops" cfg.agents) {
          source = ./agents/devops.md;
        };
      } // skillConfigs;

      homeage.file = {
        "gh-mcp-token" = {
          source = ../../modules/secrets/secrets/gh-mcp-token.age;
          symlinks = [ "${config.home.homeDirectory}/.gh-mcp-token" ];
        };
      };
    }
  );
}
