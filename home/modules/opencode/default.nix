{ config, lib, pkgs, ... }:
let
  cfg = config.massix.opencode;
  isV2 = cfg.configVersion == "v2";
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types optionalAttrs elem;

  # A server carries an `enabled` flag in the v1 dialect and the inverse
  # `disabled` flag in the v2 dialect.
  gate = enabled: if isV2 then { disabled = !enabled; } else { inherit enabled; };

  mcpServers = {
    # GitLab's native MCP server is OAuth-only (Dynamic Client
    # Registration); it has no personal-access-token/header auth yet
    # (see gitlab-org/gitlab#586184).
    gitlab = {
      type = "remote";
      url = "https://git.questel.com/api/v4/mcp";
      oauth = { };
    } // gate (elem "gitlab" cfg.mcps);
    github = {
      type = "remote";
      url = "https://api.githubcopilot.com/mcp/";
      oauth = false;
      headers = {
        Authorization = "Bearer {env:GH_MCP_TOKEN}";
      };
    } // gate (elem "github" cfg.mcps);
    gh-grep = {
      type = "remote";
      url = "https://mcp.grep.app";
    } // gate (elem "gh-grep" cfg.mcps);
    context7 = {
      type = "remote";
      url = "https://mcp.context7.com/mcp";
    } // gate (elem "context7" cfg.mcps);
    jira = {
      type = "local";
      command = [ "${pkgs.coreutils}/bin/env" "PYTHONPATH=" "${cfg.mcp-atlassian-package}/bin/mcp-atlassian" ];
      environment = {
        JIRA_URL = "https://questel.atlassian.net";
        JIRA_USERNAME = "mgengarelli@questel.com";
        JIRA_API_TOKEN = "{env:JIRA_MCP_TOKEN}";
      };
    } // gate (elem "jira" cfg.mcps);
    # INFO: COROS's remote MCP server fails to initialize under opencode v2.
    # Since v2, opencode advertises the MCP "elicitation" client capability
    # (elicitation.form.applyDefaults) during the initialize handshake, per
    # the 2025-11-25 MCP spec. COROS's server runs on the Java MCP SDK
    # (io.modelcontextprotocol.spec), and the version it's pinned to
    # deserializes that request strictly, so the unrecognized
    # "applyDefaults" field throws instead of being ignored:
    #   Unrecognized field "applyDefaults" (class
    #   io.modelcontextprotocol.spec.McpSchema$ClientCapabilities$Elicitation$Form)
    # This is a known upstream bug (modelcontextprotocol/java-sdk#724),
    # fixed in newer SDK releases, but COROS hasn't upgraded yet. OAuth
    # succeeds; the handshake right after it fails with status=failed.
    # opencode has no per-server way to opt out of advertising
    # elicitation, so keep this disabled via cfg.mcps until either side
    # ships a fix. Works fine in claude-code (v1 MCP client, no
    # elicitation capability advertised).
    coros = {
      type = "remote";
      url = "https://mcpeu.coros.com/mcp";
      oauth = { };
    } // gate (elem "coros" cfg.mcps);
    # INFO: Strava's MCP does not work with opencode at the moment.
    # opencode relies on OAuth Dynamic Client Registration (RFC 7591),
    # which Strava's authorization server does not support (it only
    # pre-registers known clients like Claude). `opencode mcp auth strava`
    # fails with "Unable to create client" / "Unable to register client".
    # Kept here (disabled via cfg.mcps) so it can be re-enabled once
    # Strava supports additional AI clients. Works fine in claude-code.
    strava = {
      type = "remote";
      url = "https://mcp.strava.com/mcp";
      oauth = { };
    } // gate (elem "strava" cfg.mcps);
  };
in
{
  options.massix.opencode = {
    enable = mkEnableOption "Enable opencode configuration";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.opencode;
      description = "Opencode package to use (or null)";
    };

    configVersion = mkOption {
      type = types.enum [ "v1" "v2" ];
      default = "v1";
      description = ''
        OpenCode configuration dialect to emit. `v1` emits the legacy shapes
        understood by OpenCode 1.x (autoupdate, mcp.<name>.enabled, provider,
        plugin, tui.json). `v2` emits the native OpenCode 2 shapes (update,
        mcp.servers.<name>.disabled, providers, plugins). Defaults to `v1`
        because nixpkgs still ships OpenCode 1.x; set `v2` on hosts running
        OpenCode 2.
      '';
    };

    # The mcp-atlassian package may not build on every platform (e.g. x86_64-darwin
    # with pinned nixpkgs). Host configs can override this with a stub or disable
    # the "jira" MCP entirely.
    mcp-atlassian-package = mkPackageOption pkgs "mcp-atlassian" { };

    mcps = mkOption {
      type = types.listOf (types.enum [ "github" "gh-grep" "context7" "gitlab" "jira" "coros" "strava" ]);
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

    extraProviders = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Providers to emit under the `provider` (v1) or `providers` (v2) map of
        opencode.json, keyed by provider id. Piped verbatim into the generated
        config, so the value shape must match the dialect selected by
        configVersion; no validation here — an invalid provider block will make
        opencode refuse to start. In the v2 dialect use `package = "aisdk:..."`,
        `settings = { ... }`, and `models`.
      '';
      example = {
        "local-mlx-lm" = {
          name = "Local mlx_lm";
          package = "aisdk:@ai-sdk/openai-compatible";
          settings.baseURL = "http://127.0.0.1:3003/v1";
          models = { };
        };
      };
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
      pkgs.nodejs_24
      pkgs.uv
    ] ++ (lib.optional (cfg.package != null) cfg.package);

    xdg.configFile = {
      "opencode/opencode.json" = {
        text = builtins.toJSON (
          {
            default_agent = cfg.defaultAgent;
            mcp = if isV2 then { servers = mcpServers; } else mcpServers;
          }
          // (if isV2 then { "$schema" = "https://opencode.ai/config.json"; } else { })
          // (if isV2
          then { update = if cfg.autoupdate then "auto" else "disable"; }
          else { inherit (cfg) autoupdate; })
          // optionalAttrs (cfg.extraProviders != { }) {
            ${if isV2 then "providers" else "provider"} = cfg.extraProviders;
          }
          // optionalAttrs cfg.claudeAuth.enable {
            ${if isV2 then "plugins" else "plugin"} = [ "opencode-claude-auth-v2@latest" ];
          }
        );
      };
    }
    // optionalAttrs (!isV2) {
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
      "jira-mcp-token" = {
        source = ./secrets/jira-mcp-token.age;
        symlinks = [ "${config.home.homeDirectory}/.jira-mcp-token" ];
      };
    };
  };
}
