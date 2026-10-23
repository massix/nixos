{ pkgs
, config
, lib
, username
, ...
}:
let
  inherit (config.home) homeDirectory;
  mkColimaAgent = import ./colima.nix { inherit lib pkgs config; };
in
{
  imports = [ ./packages.nix ];

  massix = {
    gleeter.enable = true;
    firefox.enable = false;
    fonts = {
      enable = true;
      # afdko is broken on aarch64-darwin; macOS provides its own UI font and Apple Color Emoji.
      families.exclude = with pkgs; [
        noto-fonts-color-emoji
      ];
    };
    neovim = {
      enable = true;
      configuration.package = pkgs.neovim-unwrapped;
      defaultEditor = true;
    };
    ghostty =
      let
        to-font-feature = l: builtins.concatStringsSep "," (map (x: "+${x}") l);
      in
      {
        enable = true;
        theme = "Rose Pine";
        extraPackages = with pkgs; [
          monaspace
        ];
        extraSettings = {
          font-family = "Monaspace Krypton";
          font-size = "13";
          window-height = "65";
          window-width = "190";
          font-feature = to-font-feature [
            "calt"
            "liga"
            "ss01" # !=, ===
            "ss02" # <=, >=
            "ss03" # ->, ~>
            "ss04" # </, />
            "ss05" # |>
            "ss06" # &&, ##, ++, __, ==
            "ss07" # ::
            "ss09" # <=>, >>, <<, =<<
            "ss10" # #[ #(
          ];
        };
      };
    fish = {
      enable = true;
      configuration.extraShellAbbrs = {
        j = "just";
        drs = "sudo darwin-rebuild switch --flake ~/.config/nixos#work-darwin";
      };
      configuration.extraInit = [
        "test -f ~/.gitlab-token; and set -gx GITLAB_TOKEN (cat ~/.gitlab-token)"
      ];
    };
    git = {
      enable = true;
      workRepository = {
        enabled = true;
        workRoot = "~/Development/Work/";
        workEmail = "mgengarelli@questel.com";
      };
    };
    devops = {
      enable = true;
      k9s = {
        enable = true;
        skin = "rose-pine-moon";
      };
      ansible.enable = true;
      tanzu.enable = true;
      vault.enable = true;
      terraform = {
        enable = true;
        flavour = "terraform";
      };
      kubernetes = {
        enable = true;
        colored = true;
      };
    };
    opencode = {
      enable = true;
      package = null;
      configVersion = "v2";
      # oh-my-opencode-slim's orchestrator is the intended primary; opencode's
      # session model (not the agent's) drives it, so pin `model` to the
      # orchestrator's model here (see the module's `model` option).
      defaultAgent = "orchestrator";
      model = "anthropic/claude-opus-4-8";
      # theme is not managed on v2: ~/.config/opencode/cli.json is TUI-owned.
      # coros disabled: broken on opencode v2, see home/modules/opencode's comment.
      mcps = [
        "github"
        "context7"
        "gh-grep"
        "jira"
        "gitlab"
      ];
      extraProviders."lumo" = {
        name = "Lumo (Tamed)";
        package = "aisdk:@ai-sdk/openai-compatible";
        settings = {
          baseURL = "http://127.0.0.1:3003/v1";
          apiKey = "your-secret-api-key-here";
        };
        models = {
          "lumo" = { name = "Lumo (Proton choose)"; };
          "lumo-max" = { name = "Lumo Max"; };
          "lumo-lite" = { name = "Lumo Lite"; };
        };
      };
      # oh-my-opencode-slim: an orchestrator + specialist subagents layered on
      # top of opencode. The module pins the plugin version and generates
      # ~/.opencode/oh-my-opencode-slim.json (the plugin's project layer) from
      # `settings`; Nix owns that file and it holds the preset DEFINITIONS.
      # The active selection lives in the plugin's user-layer file,
      # ~/.config/opencode/oh-my-opencode-slim.json, which `/preset` rewrites
      # in place - hence `defaultPreset` (seed only) rather than a `preset` key
      # in `settings` (which would outrank the user layer and freeze it).
      # Agents run on the Claude Enterprise models already authenticated here.
      # NOTE: no `variant` here - anthropic models expose no OpenCode variants
      # (the low/medium/high tokens are an OpenAI-style reasoning-effort knob;
      # a delegated child fails with "Variant unavailable" otherwise).
      ohMyOpencodeSlim = {
        enable = true;
        defaultPreset = "anthropic";
        settings = {
          presets.anthropic = {
            orchestrator = {
              model = "anthropic/claude-opus-4-8";
              skills = [ "*" ];
              mcps = [ "*" "!context7" ];
            };
            oracle = {
              model = "anthropic/claude-opus-4-8";
              skills = [ "simplify" ];
              mcps = [ ];
            };
            librarian = {
              model = "anthropic/claude-haiku-4-5";
              skills = [ ];
              mcps = [ "context7" "gh_grep" ];
            };
            explorer = {
              model = "anthropic/claude-haiku-4-5";
              skills = [ ];
              mcps = [ ];
            };
            designer = {
              model = "anthropic/claude-sonnet-4-6";
              skills = [ ];
              mcps = [ ];
            };
            fixer = {
              model = "anthropic/claude-sonnet-4-6";
              skills = [ ];
              mcps = [ ];
            };
          };
          # Free tier only: every agent runs on OpenCode's free Zen models, so a
          # session costs no credits. `/preset free` switches to it by rewriting
          # the user-layer file (~/.config/opencode/oh-my-opencode-slim.json);
          # this block just supplies the definition. Mirrors upstream's
          # cost-aware shape - one strong planner, one independent reviewer, and
          # the cheap/zero-retention model for the high-fan-out specialists.
          # Data handling: minimax-m3.1 / longcat-2.5 / glm-5.3 / deepseek-v4.1
          # are zero-retention; muse-spark is a Meta contributor tier whose
          # prompts may be used for training (hence designer only, not oracle).
          # `variant` is NOT universal: each model exposes its own effort levels
          # (verified against the plugin's models tool) -
          #   minimax-m3.1-flash-free  low|medium|high|xhigh|max
          #   muse-spark-1.3-*  minimal|low|medium|high|xhigh
          #   glm-5.3-flash-free and deepseek-v4.1-flash-free  low|high|max
          #   longcat-2.5-preview-free  (none - must be omitted, else the
          #   agent dies with "Variant unavailable")
          # A wrong token is not silently ignored; it fails the dispatch.
          # space-bunny-free was deprecated upstream (2026-10-19) and is gone
          # from the provider's model list; minimax-m3.1-flash-free replaces it
          # on the same effort levels and is zero-retention as well.
          presets.free = {
            orchestrator = {
              model = "opencode/minimax-m3.1-flash-free";
              variant = "high";
              skills = [ "*" ];
              mcps = [ "*" "!context7" ];
            };
            oracle = {
              model = "opencode/longcat-2.5-preview-free";
              skills = [ "simplify" ];
              mcps = [ ];
            };
            librarian = {
              model = "opencode/glm-5.3-flash-free";
              variant = "low";
              skills = [ ];
              mcps = [ "context7" "gh_grep" ];
            };
            explorer = {
              model = "opencode/glm-5.3-flash-free";
              variant = "low";
              skills = [ ];
              mcps = [ ];
            };
            designer = {
              model = "opencode/muse-spark-1.3-contributor-free";
              variant = "medium";
              skills = [ ];
              mcps = [ ];
            };
            fixer = {
              model = "opencode/deepseek-v4.1-flash-free";
              variant = "high";
              skills = [ ];
              mcps = [ ];
            };
          };
          # Heavy weight (orchestrator + oracle) runs on GitLab Duo, which is
          # included in the existing GitLab subscription; everything else stays
          # on the Anthropic subscription. This keeps the two reasoning-heavy
          # seats off Claude while the mechanical seats (scouting, docs, UI,
          # implementation) stay on Haiku/Sonnet.
          # Verified variant sets: duo opus-5-5 and gpt-6-astra both expose
          # low|medium|high|xhigh|max. The anthropic models expose no variants
          # at all, so those agents carry no `variant` key.
          #
          # CAUTION on the orchestrator seat: the duo GPT-6 family
          # (`duo-chat-gpt-6-1-sol`, `duo-chat-gpt-6-sol`) cannot be trusted to
          # dispatch. They invent session ids ("ses_invalid", a bare "ses_")
          # instead of threading the real one, so every background delegation
          # dies with "cannot resolve this sessionID". The duo Claude models
          # (`opus-5-5`, `sonnet-5-5`) thread it correctly, which is why the
          # orchestrator is opus-5-5. GPT-6-astra is still fine as a leaf agent
          # (oracle) - it only has to answer, not track sessions.
          presets.duo = {
            orchestrator = {
              model = "gitlab/duo-chat-opus-5-5";
              variant = "high";
              skills = [ "*" ];
              mcps = [ "*" "!context7" ];
            };
            oracle = {
              model = "gitlab/duo-chat-gpt-6-astra";
              variant = "high";
              skills = [ "simplify" ];
              mcps = [ ];
            };
            librarian = {
              model = "anthropic/claude-haiku-4-5";
              skills = [ ];
              mcps = [ "context7" "gh_grep" ];
            };
            explorer = {
              model = "anthropic/claude-haiku-4-5";
              skills = [ ];
              mcps = [ ];
            };
            designer = {
              model = "anthropic/claude-sonnet-4-6";
              skills = [ ];
              mcps = [ ];
            };
            fixer = {
              model = "anthropic/claude-sonnet-4-6";
              skills = [ ];
              mcps = [ ];
            };
          };
        };
      };
    };
    claude-code = {
      enable = true;
      mcps = [
        "github"
        "context7"
        "gh-grep"
        "jira"
        "gitlab"
        "coros"
        "strava"
      ];
    };
  };
  programs = {
    home-manager.enable = true;
    sofka = {
      enable = true;
      configFile = ./files/sofka.config.toml;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.disable_stdin = true;
        global.strict_env = true;

        whitelist.prefix = [
          "${homeDirectory}/dev"
          "${homeDirectory}/Development"
          "${homeDirectory}/.config/nvim"
          "${homeDirectory}/.config/nixos"
        ];
      };
    };
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "nvim";
      };
    };
  };

  homeage.file = {
    avp = {
      source = ./secrets/avp.age;
      symlinks = [ "${homeDirectory}/.ansible-vault-password" ];
    };
    zerotrust-root = {
      source = ./secrets/zerotrust/zerotrust-root.crt.age;
      copies = [ "${homeDirectory}/.certs/dockerregistry.prd.questel.fr/zerotrust-root.crt" ];
    };
    zerotrust-intermediate = {
      source = ./secrets/zerotrust/zerotrust-intermediate.crt.age;
      copies = [ "${homeDirectory}/.certs/dockerregistry.prd.questel.fr/zerotrust-intermediate.crt" ];
    };
    gitlab-token = {
      source = ../modules/opencode/secrets/gitlab-token.age;
      symlinks = [ "${homeDirectory}/.gitlab-token" ];
    };
  };

  # Packages from nixpkgs — custom darwin derivations live in ./packages.nix.
  home.packages =
    let
      limaWithGuests = pkgs.lima.override {
        withAdditionalGuestAgents = true;
      };
    in
    with pkgs; [
      # This does not come installed by default on MacOS
      gcc
      docker
      limaWithGuests
      colima
      lumo-tamer
    ];

  home.sessionVariables = {
    K9S_CONFIG_DIR = "${homeDirectory}/.config/k9s";
    ANSIBLE_CONFIG = "${homeDirectory}/.ansible.cfg";
    ANSIBLE_VAULT_PASSWORD_FILE = "${homeDirectory}/.ansible-vault-password";
    GITLAB_INSTANCE_URL = "https://git.questel.com";
    GLEETER_SSL_CERT_FILE = config.homeage.file.zerotrust-intermediate.path;
    NODE_EXTRA_CA_CERTS = config.homeage.file.zerotrust-intermediate.path;
  };

  home.file.".ansible.cfg" = {
    text = ''
      [defaults]
      vault_password_file = ${homeDirectory}/.ansible-vault-password
      host_key_checking = false

      [inventory]
      enable_plugins = vmware_vm_inventory, yaml
    '';
  };

  launchd.enable = true;
  launchd.agents = {
    tamer-server = {
      enable = true;
      config = {
        Label = "massix.tamer.server";
        ProgramArguments = [ "${lib.getExe pkgs.lumo-tamer}" "server" ];

        RunAtLoad = true;
        KeepAlive = true;

        WorkingDirectory = homeDirectory;
        # launchd creates the log files but not their parent directory.
        StandardOutPath = "${homeDirectory}/Library/Logs/lumo-tamer/server.log";
        StandardErrorPath = "${homeDirectory}/Library/Logs/lumo-tamer/server.err.log";

        # Agents do not inherit home.sessionVariables: HOME drives lumo-tamer's
        # state-dir resolution (~/.local/share/lumo-tamer), and the corporate
        # interception CA is required for TLS to Proton's API.
        EnvironmentVariables = {
          HOME = homeDirectory;
          PATH = "${pkgs.lumo-tamer}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          NODE_EXTRA_CA_CERTS = config.homeage.file.zerotrust-intermediate.path;
        };
      };
    };
    colima-aarch64 = mkColimaAgent {
      enable = true;
      arch = "aarch64";
      memory = 14;
      numCpus = 8;
      profileName = "aarch64";
      diskSize = 250;
    };
    colima-x86_64 = mkColimaAgent {
      enable = true;
      arch = "x86_64";
      memory = 14;
      numCpus = 8;
      maxCpu = true;
      profileName = "x86_64";
      diskSize = 250;
    };
  };

  # launchd never creates the parent directory of Standard{Out,Error}Path, and
  # it must exist before setupLaunchAgents bootstraps the tamer agent above.
  home.activation.tamerServerLogDir = lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
    run mkdir -p ${homeDirectory}/Library/Logs/lumo-tamer
  '';

  nix = {
    gc.automatic = true;
    gc.options = "--delete-older-than 10d";
    settings = {
      auto-optimise-store = false;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = true;
      trusted-users = [ "root" username ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "surface-zen.cachix.org-1:8OXCpyGHk4UL+BDkgJYW1bGf/ULbNGKLiBjaTELJwaQ="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://surface-zen.cachix.org"
        "https://cache.nixos.org"
      ];
    };
    registry = {
      nix-darwin = {
        from = {
          id = "nix-darwin";
          type = "indirect";
        };
        to = {
          owner = "nix-darwin";
          repo = "nix-darwin";
          type = "github";
        };
      };
    };
  };

  xdg.configFile."fish/functions/kcon.fish".source = ./files/kcon.fish;
  xdg.configFile."fish/conf.d/rapid-log.fish".source = ./files/rapid-log.fish;

  # Global colima override applied to every profile. Trusts the Zerotrust CA
  # chain inside all VMs: relies on the `--mount` of the certs into
  # /etc/docker/certs.d (see mkColimaAgent above); runs on every VM boot.
  home.file.".colima/_lima/_config/override.yaml".text = ''
    provision:
      - mode: system
        script: |
          #!/bin/bash
          set -eux -o pipefail
          mkdir -p /usr/local/share/ca-certificates
          find /etc/docker/certs.d/dockerregistry.prd.questel.fr \
            -maxdepth 1 -type f \( -name '*.crt' -o -name '*.pem' \) \
            -exec cp {} /usr/local/share/ca-certificates/ \;
          chmod 644 /usr/local/share/ca-certificates/*
          update-ca-certificates
  '';
}
