{ config, lib, pkgs, ... }:
let
  cfg = config.massix.claude-code;
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types filterAttrs optionalString;

  # Full catalogue of supported MCP servers. Only those listed in `cfg.mcps`
  # are emitted into the generated config. Secrets are referenced through
  # environment variables (expanded by Claude Code at startup) and are provided
  # elsewhere (see home/modules/fish.nix).
  allServers = {
    gitlab = {
      type = "stdio";
      command = "npx";
      args = [ "-y" "@structured-world/gitlab-mcp" ];
      env = {
        GITLAB_TOKEN = "\${GITLAB_MCP_TOKEN}";
        GITLAB_API_URL = "https://git.questel.com";
      };
    };
    github = {
      type = "http";
      url = "https://api.githubcopilot.com/mcp/";
      headers = {
        Authorization = "Bearer \${GH_MCP_TOKEN}";
      };
    };
    gh-grep = {
      type = "http";
      url = "https://mcp.grep.app";
    };
    context7 = {
      type = "http";
      url = "https://mcp.context7.com/mcp";
    };
    jira = {
      type = "stdio";
      command = "uvx";
      args = [ "mcp-atlassian" ];
      env = {
        JIRA_URL = "https://jira.questel.com";
        JIRA_PERSONAL_TOKEN = "\${JIRA_MCP_TOKEN}";
      };
    };
    coros = {
      type = "http";
      url = "https://mcpeu.coros.com/mcp";
    };
    strava = {
      type = "http";
      url = "https://mcp.strava.com/mcp";
    };
  };

  enabledServers = filterAttrs (name: _: builtins.elem name cfg.mcps) allServers;
in
{
  options.massix.claude-code = {
    enable = mkEnableOption "Enable claude-code configuration";

    package = mkPackageOption pkgs "claude-code" {
      default = "claude-code";
    };

    mcps = mkOption {
      type = types.listOf (types.enum [ "github" "gh-grep" "context7" "gitlab" "jira" "coros" "strava" ]);
      default = [ ];
      description = "MCP servers to enable";
      example = [ "github" "context7" "jira" ];
    };

    strict = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Pass --strict-mcp-config so Claude Code only loads the MCP servers from
        the generated config, ignoring project-level .mcp.json and ~/.claude.json.
      '';
    };

    disableAutoupdate = mkOption {
      type = types.bool;
      default = true;
      description = "Disable claude-code's self-updater (binary lives read-only in the nix store)";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
      pkgs.nodejs_24
      pkgs.uv
    ];

    # Read-only MCP configuration. Claude Code never mutates this file (unlike
    # ~/.claude.json), so it is safe to manage as a nix symlink. It is loaded via
    # the `--mcp-config` flag set on the shell alias below.
    home.file.".claude/mcp.json" = {
      text = builtins.toJSON {
        mcpServers = enabledServers;
      };
    };

    # `command` prefix avoids the alias recursively invoking itself.
    programs.fish.shellAliases.claude =
      "command claude ${optionalString cfg.strict "--strict-mcp-config "}--mcp-config ${config.home.homeDirectory}/.claude/mcp.json";

    home.sessionVariables = mkIf cfg.disableAutoupdate {
      DISABLE_AUTOUPDATER = "1";
    };
  };
}
