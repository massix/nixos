{ config, lib, pkgs, ... }:
let
  cfg = config.massix.opencode;
  isV2 = cfg.configVersion == "v2";
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types optionalAttrs optional elem;

  # Plugin entries registered in opencode.json.
  plugins = optional cfg.claudeAuth.enable "opencode-claude-auth-v2@latest";

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

  rule = effect: action: resource: { inherit action resource effect; };
  allow = rule "allow";
  deny = rule "deny";
  ask = rule "ask";

  # Zeus never edits files. His shell is allowed by default, with a deny list
  # of obvious write commands (denied, not asked, so he delegates instead).
  # Rule order matters (last match wins, and every subcommand of a compound
  # command is checked separately):
  #   1. redirects are denied, then the harmless stderr redirects are re-allowed;
  #   2. a few more redirect forms (`> file`, `>>`, `&>`, `1>`) are denied again,
  #      so `cmd > out 2>&1` is still refused;
  #   3. the command deny list comes LAST, so it always wins (a re-allow such
  #      as `*2>&1*` can never override a denied `rm foo 2>&1`).
  # This is best effort: the prompt is the real guard. `python3 -c`, `curl -X`,
  # `git branch <name>`, `git tag <name>`, `git config <key> <value>`, `cmd>out
  # 2>&1` and similar can still write, and are forbidden by the prompt only.
  # Where a blanket deny would also block read-only use (`git stash list`,
  # `kubectl rollout status`, `systemctl status`, ...), only the mutating
  # subcommands are listed.
  zeusShellDeny = [
    # Files
    "rm *" "rmdir *" "mv *" "cp *" "mkdir *" "touch *" "chmod *" "chown *" "ln *"
    "tee *" "dd *" "truncate *" "install *" "rsync *" "unlink *" "shred *"
    "sed *-i*" "sed *--in-place*" "perl *-i*"
    "find *-delete*" "find *-exec*" "xargs *" "sudo *"

    # Git: working tree, index and history
    "git add *" "git commit *" "git switch *" "git checkout *"
    "git pull *" "git push *" "git merge *" "git rebase *"
    "git cherry-pick *" "git revert *" "git mv *" "git rm *" "git reset *"
    "git restore *" "git clean *" "git am *" "git apply *"
    "git init *" "git clone *" "git update-ref *" "git gc *"
    # Git: stash (`git stash list` and `git stash show` stay readable)
    "git stash" "git stash -*" "git stash push *" "git stash pop *"
    "git stash apply *" "git stash drop *" "git stash clear *"
    "git stash save *" "git stash branch *"
    # Git: branch and tag flags (listing stays readable; creating a plain
    # `git branch name` or `git tag name` cannot be pattern-blocked)
    "git branch *-d*" "git branch *-D*" "git branch *-M*" "git branch *-C*"
    "git branch -m*" "git branch * -m*" "git branch -c*" "git branch * -c*"
    "git branch -f*" "git branch * -f*" "git branch *-u *"
    "git branch *--delete*" "git branch *--move*" "git branch *--copy*"
    "git branch *--force*" "git branch *--set-upstream*"
    "git tag -a*" "git tag * -a*" "git tag -d*" "git tag * -d*"
    "git tag -f*" "git tag * -f*" "git tag -s*" "git tag * -s*"
    "git tag -m*" "git tag * -m*"
    "git tag *--annotate*" "git tag *--delete*" "git tag *--force*" "git tag *--sign*"
    # Git: worktrees, remotes and config (read-only subcommands stay readable)
    "git worktree add *" "git worktree remove *" "git worktree move *"
    "git worktree prune *" "git worktree lock *" "git worktree unlock *"
    "git worktree repair *"
    "git remote add *" "git remote remove *" "git remote rm *"
    "git remote set-url *" "git remote rename *"
    "git config *--add*" "git config *--unset*" "git config *--replace-all*"
    "git config *--edit*" "git config -e*" "git config *--remove-section*"
    "git config *--rename-section*"

    # Cluster
    "kubectl apply *" "kubectl create *" "kubectl delete *" "kubectl edit *"
    "kubectl patch *" "kubectl replace *" "kubectl scale *" "kubectl set *"
    "kubectl label *" "kubectl annotate *" "kubectl cordon *" "kubectl drain *"
    "kubectl uncordon *" "kubectl taint *" "kubectl exec *" "kubectl cp *"
    "kubectl rollout restart *" "kubectl rollout undo *"
    "kubectl rollout pause *" "kubectl rollout resume *"
    "helm install *" "helm upgrade *" "helm uninstall *" "helm delete *"
    "helm rollback *" "helm repo add *" "helm repo remove *"

    # System and package managers
    "darwin-rebuild *" "nixos-rebuild *" "home-manager *" "nix-env *"
    "nix-collect-garbage *" "nix store gc *" "nix store delete *"
    "nix flake update *" "nix flake lock *"
    "nix profile install *" "nix profile remove *" "nix profile upgrade *"
    "nix profile rollback *" "nix profile wipe-history *"
    "brew install *" "brew uninstall *" "brew upgrade *" "brew update *"
    "brew tap *" "brew untap *" "brew link *" "brew unlink *" "brew cleanup *"
    "npm install *" "npm i *" "npm ci *" "npm uninstall *" "npm publish *"
    "pnpm install *" "pnpm add *" "yarn add *" "yarn install *"
    "pip install *" "pip uninstall *" "pip3 install *" "uv pip install *" "uv add *"
    "cargo install *" "go install *"
    "launchctl load *" "launchctl unload *" "launchctl bootstrap *"
    "launchctl bootout *" "launchctl kickstart *" "launchctl kill *"
    "launchctl enable *" "launchctl disable *" "launchctl submit *"
    "launchctl remove *" "launchctl start *" "launchctl stop *"
    "systemctl start *" "systemctl stop *" "systemctl restart *"
    "systemctl reload *" "systemctl enable *" "systemctl disable *"
    "systemctl mask *" "systemctl unmask *" "systemctl daemon-reload *"
    "systemctl edit *" "systemctl kill *"
    "kill *" "killall *" "pkill *"
    "opencode service start *" "opencode service stop *" "opencode service restart *"
  ];

  zeusRules = [
    (deny "edit" "*")
    (deny "shell" "*>*")
    (allow "shell" "*2>&1*")
    (allow "shell" "*2>/dev/null*")
    (deny "shell" "* >*")
    (deny "shell" "*>>*")
    (deny "shell" "*&>*")
    (deny "shell" "*1>*")
  ]
  ++ map (deny "shell") zeusShellDeny;

  # Git operations that prompt the user. Hades has full rights by default, so
  # only the destructive and history-rewriting operations are listed (last
  # match wins; nothing precedes them in his ruleset). The patterns
  # intentionally over-match (e.g. branch names containing `-f` or `-d`) to
  # avoid flag-combination bypasses.
  gitAskRules =
    map (ask "shell") [
      "git push *--force*" "git push *-f*" "git push *--delete*" "git push * :*"
      "git push *+*" "git reset *--hard*" "git clean *" "git branch *-D*"
      "git branch *-d*" "git branch *--delete*" "git tag *-d*" "git tag *--delete*"
      "git restore *" "git checkout *-- *" "git stash drop *" "git stash clear *"
    ]
    # Guard history rewrites and discarding of uncommitted work.
    ++ map (ask "shell") [
      "git commit *--amend*" "git rebase *" "git reset *"
      "git push *--mirror*" "git push *--prune*"
      "git checkout *--force*" "git checkout -f*" "git checkout * -f*"
      "git checkout ." "git checkout * ."
      "git switch *--discard-changes*" "git switch *--force*"
      "git switch -f*" "git switch * -f*"
      "git branch *-f*" "git branch *-M*" "git branch *-C*" "git tag *-f*"
    ];

  agentModel = cfg.agents;

  # Markdown section appended to Zeus's prompt, listing every agent's fallback
  # chain (OpenCode has no native fallback: Zeus re-launches a failed subagent
  # with the `model` parameter of the `subagent` tool).
  chainLine = label: models:
    "- ${label}: ${lib.concatMapStringsSep " → " (m: "`${m}`") models}";
  fallbackSection = ''
    # Model fallback chains

    ${lib.concatStringsSep "\n" [
      (chainLine "**zeus** (you)" agentModel.zeus.models)
      (chainLine "**athena**" agentModel.athena.models)
      (chainLine "**poseidon**" agentModel.poseidon.models)
      (chainLine "**hades**" agentModel.hades.models)
    ]}
  '';

  agentsConfig = {
    zeus = {
      description = "Main orchestrator: understands requests, plans, delegates. Never modifies anything itself.";
      mode = "primary";
      model = builtins.head agentModel.zeus.models;
      color = "#f5c518";
      system = builtins.readFile ./agents/zeus.md + "\n" + fallbackSection;
      permissions = zeusRules ++ [
        (deny "subagent" "*")
        (allow "subagent" "athena")
        (allow "subagent" "poseidon")
        (allow "subagent" "hades")
        (allow "subagent" "explore")
        (allow "subagent" "general")
      ];
    };
    athena = {
      description = "Executes configuration changes (Nix, Kubernetes manifests, YAML/JSON/TOML, anything that is not code). Only launched by Zeus, with an explicit PHASE header.";
      mode = "subagent";
      model = builtins.head agentModel.athena.models;
      color = "#4fa3d9";
      system = builtins.readFile ./agents/athena.md;
      permissions = [ (deny "subagent" "*") ];
    };
    poseidon = {
      description = "Executes code and development changes (source, tests, non-Nix build systems). Only launched by Zeus, with an explicit PHASE header.";
      mode = "subagent";
      model = builtins.head agentModel.poseidon.models;
      color = "#1fb5a8";
      system = builtins.readFile ./agents/poseidon.md;
      permissions = [ (deny "subagent" "*") ];
    };
    hades = {
      description = "Handles small, quick tasks of any kind (lookups, explanations, small edits) and performs all git operations that change a repository (branches, commits, tags, push). Writes only when ordered with PHASE: EXECUTE. Cheap and fast.";
      mode = "subagent";
      model = builtins.head agentModel.hades.models;
      color = "#8e44ad";
      system = builtins.readFile ./agents/hades.md;
      permissions = gitAskRules ++ [ (deny "subagent" "*") ];
    };
  };

  mkAgentModelsOption = default: description: mkOption {
    type = types.nonEmptyListOf types.str;
    inherit default;
    description = ''
      ${description}

      Ordered fallback chain (`provider/model[#variant]`). The first entry is
      the agent's configured model; the following ones are used by Zeus to
      re-launch a subagent when its provider is out of credits or unavailable.
      For Zeus himself, the following entries are only suggested to the user,
      who switches with `/models`.
    '';
    example = [ "anthropic/claude-sonnet-5-5#high" "gitlab/duo-chat-sonnet-5-5" ];
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
        Top-level default model (`provider/model`).
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

    agents = {
      enable = mkEnableOption ''
        the Olympian agent set (Zeus, Athena, Poseidon, Hades). Requires
        configVersion = "v2"
      '';
      hideBuiltins = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Disable OpenCode's built-in `build` and `plan` primary agents (via
          `disabled = true`) so only the custom agents are selectable. `explore`
          and `general` are kept because Zeus delegates to them. Requires
          agents.enable.
        '';
      };
      # INFO: the opencode/* free entries were chosen as privacy-safe only (no
      # training on data): Beam Free, DeepSeek V4.1 Flash Free and GLM-5.3-Flash
      # Free. Big Pickle, Pulse, Crouton, Flint, MiMo and Nemotron are excluded.
      # Free models are time-limited, so these IDs may need updating.
      zeus.models = mkAgentModelsOption
        [ "anthropic/claude-opus-5-5" "gitlab/duo-chat-opus-5-5" "opencode/beam-free" ]
        "Models for Zeus, the orchestrator. Should have a context window of at least 1M tokens.";
      athena.models = mkAgentModelsOption
        [ "anthropic/claude-sonnet-5-5" "gitlab/duo-chat-sonnet-5-5" "opencode/beam-free" "opencode/deepseek-v4.1-flash-free" ]
        "Models for Athena, the configuration executor.";
      poseidon.models = mkAgentModelsOption
        [ "anthropic/claude-sonnet-5-5" "gitlab/duo-chat-sonnet-5-5" "opencode/beam-free" "opencode/deepseek-v4.1-flash-free" ]
        "Models for Poseidon, the code executor.";
      hades.models = mkAgentModelsOption
        [ "anthropic/claude-haiku-5-5" "gitlab/duo-chat-haiku-5-5" "opencode/deepseek-v4.1-flash-free" "opencode/glm-5.3-flash-free" ]
        "Models for Hades, the quick read-only helper.";
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
      {
        assertion = !cfg.agents.enable || isV2;
        message = ''
          massix.opencode.agents.enable requires massix.opencode.configVersion = "v2"
          (the agent permissions are emitted in the v2 dialect only).
        '';
      }
      {
        assertion = !cfg.agents.hideBuiltins || cfg.agents.enable;
        message = ''
          massix.opencode.agents.hideBuiltins requires massix.opencode.agents.enable = true
          (otherwise the built-in build/plan agents would be disabled and no
          primary agent would remain).
        '';
      }
      {
        assertion = !cfg.agents.hideBuiltins || !(builtins.elem cfg.defaultAgent [ "build" "plan" ]);
        message = ''
          massix.opencode.defaultAgent must not be "build" or "plan" when
          massix.opencode.agents.hideBuiltins = true (those agents are disabled).
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
          // optionalAttrs cfg.agents.enable {
            agents = agentsConfig
              // optionalAttrs cfg.agents.hideBuiltins {
                build = { disabled = true; };
                plan = { disabled = true; };
              };
          }
          // optionalAttrs (plugins != [ ]) {
            ${if isV2 then "plugins" else "plugin"} = plugins;
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

    home.sessionVariables = {
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
