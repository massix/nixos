{ config, lib, pkgs, ... }:
let
  cfg = config.massix.opencode;
  isV2 = cfg.configVersion == "v2";
  slim = cfg.ohMyOpencodeSlim;
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types optionalAttrs optional elem;

  # Plugin entries registered in opencode.json. `oh-my-opencode-slim` is pinned
  # to an exact version on purpose: an unpinned (`@latest`) npm plugin
  # auto-upgrades on every OpenCode v2 start, and the pin is the true lock.
  plugins =
    optional cfg.claudeAuth.enable "opencode-claude-auth-v2@latest"
    ++ optional slim.enable "oh-my-opencode-slim@${slim.version}";

  # Contents of ~/.opencode/oh-my-opencode-slim.json: the plugin's PROJECT
  # layer, which Nix owns (symlinked, never rewritten by the plugin). It holds
  # the preset DEFINITIONS and per-agent model mappings. `$schema` comes first
  # so `settings` can still override it.
  #
  # The plugin's USER layer is ~/.config/opencode/oh-my-opencode-slim.json: it
  # holds only the active `preset` selection and the plugin rewrites it on
  # every `/preset` (atomic rename), so it is deliberately NOT Nix-managed.
  # Project layers merge after (and outrank) the user layer, so this file must
  # NEVER carry a top-level `preset` key - it would freeze the selection. Use
  # the module's `defaultPreset` option to seed the user layer instead.
  slimConfig =
    {
      "$schema" = "https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json";
    }
    // slim.settings;

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

    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Top-level default model (`provider/model`). OpenCode's session model
        overrides an agent's own configured model, so this is what actually
        drives the primary agent. With oh-my-opencode-slim, set this to the
        orchestrator's model so the orchestrator runs on it (its own
        `presets.<name>.orchestrator.model` only governs dispatched children).
      '';
      example = "anthropic/claude-opus-4-8";
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

    ohMyOpencodeSlim = {
      enable = mkEnableOption "the oh-my-opencode-slim orchestration plugin";

      version = mkOption {
        type = types.str;
        default = "3.0.4";
        description = ''
          oh-my-opencode-slim version registered in opencode's plugin list.
          Pinned deliberately: on OpenCode v2 an unpinned (`@latest`) npm plugin
          auto-upgrades on every startup, so the pin is the only true lock.
        '';
      };

      settings = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Contents of ~/.opencode/oh-my-opencode-slim.json: the plugin's
          Nix-managed project layer, holding the preset DEFINITIONS (per-agent
          model mappings, `council`, etc.). Piped verbatim into the generated
          JSON; no validation here, so an invalid value will make the plugin
          reject its config.

          Do NOT set a top-level `preset` here: project layers take merge
          precedence over the user layer, so it would override (and freeze) the
          active selection in ~/.config/opencode/oh-my-opencode-slim.json,
          which the plugin rewrites on `/preset`. Use `defaultPreset` instead.
        '';
        example = {
          presets.anthropic.orchestrator.model = "anthropic/claude-opus-4-8";
        };
      };

      defaultPreset = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Preset name seeded into the plugin's user-layer file
          (~/.config/opencode/oh-my-opencode-slim.json) the first time it is
          missing. That file holds ONLY the active preset selection - the
          plugin rewrites it whenever `/preset` runs, so it cannot be
          Nix-managed. Set to null to skip seeding entirely.
        '';
        example = "anthropic";
      };

      backgroundSubagents = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Export OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true and
          OPENCODE_ENABLE_EXA=1. Required for the plugin's default background
          orchestration workflow, and enables OpenCode's built-in websearch
          without an API key.
        '';
      };

      disableDefaultAgents = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Disable opencode's built-in `explore` and `general` subagents. The
          plugin ships its own specialists and expects to own delegation.
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
      {
        assertion = !slim.enable || (slim.settings.preset or null) == null;
        message = ''
          massix.opencode.ohMyOpencodeSlim.settings.preset is set, but the
          active preset lives in the plugin's user-layer file
          (~/.config/opencode/oh-my-opencode-slim.json), which `/preset`
          rewrites. The Nix-managed project layer
          (~/.opencode/oh-my-opencode-slim.json) takes merge precedence and
          would override the user's choice. Use
          massix.opencode.ohMyOpencodeSlim.defaultPreset to seed the
          user-layer file instead.
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
          // optionalAttrs (cfg.model != null) { inherit (cfg) model; }
          // (if isV2 then { "$schema" = "https://opencode.ai/config.json"; } else { })
          // (if isV2
          then { update = if cfg.autoupdate then "auto" else "disable"; }
          else { inherit (cfg) autoupdate; })
          // optionalAttrs (cfg.extraProviders != { }) {
            ${if isV2 then "providers" else "provider"} = cfg.extraProviders;
          }
          // optionalAttrs (plugins != [ ]) {
            ${if isV2 then "plugins" else "plugin"} = plugins;
          }
          # oh-my-opencode-slim wants OpenCode's LSP integration enabled and the
          # built-in `explore`/`general` subagents disabled (it ships its own).
          // optionalAttrs slim.enable { lsp = true; }
          // optionalAttrs (slim.enable && slim.disableDefaultAgents) {
            agent = {
              explore.disable = true;
              general.disable = true;
            };
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

    # The plugin's project layer (preset definitions). A plain `home.file`
    # symlink, not an `xdg.configFile`, because the plugin also reads ancestor
    # `./.opencode` dirs and this is the one at $HOME.
    home.file = optionalAttrs slim.enable {
      ".opencode/oh-my-opencode-slim.json" = {
        text = builtins.toJSON slimConfig;
      };
    };

    # The plugin refuses to switch presets while its user-layer file is
    # missing, so seed it once with the default selection and then leave it to
    # the plugin (which rewrites it on `/preset`).
    home.activation = optionalAttrs (slim.enable && slim.defaultPreset != null) {
      seedSlimPresetSelection = lib.hm.dag.entryAfter [ "installPackages" ] ''
        # The plugin's user-layer file holds ONLY the active preset; `/preset`
        # rewrites it in place, so it must not be a Nix-managed symlink.
        # Seed it on first activation, then leave it to the plugin.
        target=${config.home.homeDirectory}/.config/opencode/oh-my-opencode-slim.json
        if [ ! -e "$target" ]; then
          mkdir -p "$(dirname "$target")"
          printf '%s\n' '${builtins.toJSON { preset = slim.defaultPreset; }}' > "$target"
          echo "seeded $target with preset ${slim.defaultPreset}"
        fi
      '';
    };

    # The plugin's default background-orchestration workflow (and its built-in
    # websearch) needs these exported at OpenCode launch.
    home.sessionVariables = optionalAttrs (slim.enable && slim.backgroundSubagents) {
      OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS = "true";
      OPENCODE_ENABLE_EXA = "1";
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
