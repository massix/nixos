{ config, lib, pkgs, ... }:
let
  cfg = config.massix.claude-code;
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types filterAttrs optionalString optionalAttrs;

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
      command = "${pkgs.coreutils}/bin/env";
      args = [ "PYTHONPATH=" "${pkgs.mcp-atlassian}/bin/mcp-atlassian" ];
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

  # Statusline shown at the bottom of the Claude Code TUI. Wrapped with its
  # runtime deps so it works standalone regardless of what's on PATH.
  claudeStatusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [ pkgs.bash pkgs.jq pkgs.git ];
    text = builtins.readFile ./files/statusline.sh;
  };
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

    coAuthor = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Include Claude's attribution in git commits and PRs (the
        "Co-Authored-By: Claude" commit trailer and the "Generated with
        Claude Code" pull request line). When false, both are suppressed via
        the `attribution` setting in the injected extended settings file.
      '';
    };

    theme = mkOption {
      type = types.str;
      default = "auto";
      description = ''
        Claude Code UI color theme written into the injected extended settings
        file. One of "auto", "dark", "light", "dark-daltonized",
        "light-daltonized", "dark-ansi", "light-ansi", or a "custom:<slug>"
        reference.
      '';
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

    # Read-only extended settings file injected via the `--settings` flag on
    # the alias below. We deliberately avoid managing ~/.claude/settings.json
    # directly: Claude Code reads AND writes that file (advisor model, /config
    # preferences, backups), so a nix symlink would break those writes. This
    # separate file is never touched by Claude Code and merges at command-line
    # precedence (above user/project/local, below managed). Empty
    # `commit`/`pr` strings hide the "Co-Authored-By: Claude" trailer and the
    # "Generated with Claude Code" PR line respectively.
    home.file.".claude/nix-settings.json".text = builtins.toJSON (
      {
        inherit (cfg) theme;
        statusLine = {
          type = "command";
          command = "${claudeStatusline}/bin/claude-statusline";
        };
      }
      // optionalAttrs (!cfg.coAuthor) {
        attribution = {
          commit = "";
          pr = "";
        };
      }
    );

    # `command` prefix avoids the alias recursively invoking itself.
    programs.fish.shellAliases.claude =
      "command claude ${optionalString cfg.strict "--strict-mcp-config "}--mcp-config ${config.home.homeDirectory}/.claude/mcp.json --settings ${config.home.homeDirectory}/.claude/nix-settings.json";

    home.sessionVariables = mkIf cfg.disableAutoupdate {
      DISABLE_AUTOUPDATER = "1";
    };
  };
}
