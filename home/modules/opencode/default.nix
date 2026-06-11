{ config, lib, pkgs, ... }:
let
  cfg = config.massix.opencode;
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types optionalAttrs;
in
{
  options.massix.opencode = {
    enable = mkEnableOption "Enable opencode configuration";

    package = mkPackageOption pkgs "opencode" {
      default = "opencode";
    };

    mcps = mkOption {
      type = types.listOf (types.enum [ "github" "gh-grep" "context7" "gitlab" "jira" "coros" ]);
      default = [ ];
      description = "MCP servers to enable";
      example = [ "github" "context7" "jira" ];
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

    autoupdate = mkOption {
      type = types.bool;
      default = false;
      description = "Disable opencode's automatic update popup";
    };

    claudeAuth = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Install the opencode-claude-auth plugin so opencode reuses Claude Code's
          OAuth credentials. Requires massix.claude-code.enable = true.
        '';
      };

      enable1mContext = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable 1M-token context (Claude Max) for the opencode-claude-auth plugin
          via agent.build.enable1mContext. Only emitted when claudeAuth.enable is true.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.claudeAuth.enable || config.massix.claude-code.enable;
        message = ''
          massix.opencode.claudeAuth.enable requires massix.claude-code.enable = true
          (the opencode-claude-auth plugin reuses Claude Code's OAuth credentials,
          which only exist once Claude Code has been installed and authenticated).
        '';
      }
    ];

    home.packages = [
      cfg.package
      pkgs.nodejs_24
      pkgs.uv
    ];

    xdg.configFile = {
      "opencode/opencode.json" = {
        text = builtins.toJSON (
          {
            inherit (cfg) autoupdate;
            default_agent = cfg.defaultAgent;
            mcp = {
              gitlab = {
                type = "local";
                command = [ "npx" "-y" "@structured-world/gitlab-mcp" ];
                environment = {
                  GITLAB_TOKEN = "{env:GITLAB_MCP_TOKEN}";
                  GITLAB_API_URL = "https://git.questel.com";
                };
                enabled = builtins.elem "gitlab" cfg.mcps;
              };
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
              jira = {
                type = "local";
                command = [ "uvx" "mcp-atlassian" ];
                environment = {
                  JIRA_URL = "https://jira.questel.com";
                  JIRA_PERSONAL_TOKEN = "{env:JIRA_MCP_TOKEN}";
                };
                enabled = builtins.elem "jira" cfg.mcps;
              };
              coros = {
                type = "remote";
                url = "https://mcpeu.coros.com/mcp";
                oauth = { };
                enabled = builtins.elem "coros" cfg.mcps;
              };
            };
          }
          // optionalAttrs cfg.claudeAuth.enable {
            plugin = [ "opencode-claude-auth@latest" ];
          }
          // optionalAttrs (cfg.claudeAuth.enable && cfg.claudeAuth.enable1mContext) {
            agent.build.enable1mContext = true;
          }
        );
      };
      "opencode/tui.json" = {
        text = builtins.toJSON {
          inherit (cfg) theme;
        };
      };
    };

    homeage.file = {
      "gh-mcp-token" = {
        source = ./secrets/gh-mcp-token.age;
        symlinks = [ "${config.home.homeDirectory}/.gh-mcp-token" ];
      };
      "gitlab-mcp-token" = {
        source = ./secrets/gitlab-mcp-token.age;
        symlinks = [ "${config.home.homeDirectory}/.gitlab-mcp-token" ];
      };
      "jira-mcp-token" = {
        source = ./secrets/jira-mcp-token.age;
        symlinks = [ "${config.home.homeDirectory}/.jira-mcp-token" ];
      };
    };
  };
}
