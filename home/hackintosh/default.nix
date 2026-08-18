{ pkgs
, config
, username
, ...
}:
let
  inherit (config.home) homeDirectory;
  inherit (pkgs) lib;
in
{
  massix = {
    firefox = {
      enable = false;
    };
    fonts = {
      enable = true;
      # Exclude emoji fonts — the Hackintosh relies on macOS-provided UI fonts
      # and Noto Color Emoji does not build reliably on x86_64-darwin.
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
        add-plus = l: map (x: "+${x}") l;
        to-font-feature = l: builtins.concatStringsSep "," (add-plus l);
      in
      {
        enable = true;
        package = null;
        theme = "TokyoNight";
        extraSettings = {
          background-blur = "false";
          background-opacity = "1.0";
          font-family = "Kode Mono";
          font-size = "12";
          window-height = "65";
          window-width = "190";
          font-feature = to-font-feature [
            "calt"
            "ss01"
            "lig"
          ];
        };
      };
    fish = {
      enable = true;
      configuration.extraShellAbbrs = {
        j = "just";
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
      enable = false;
    };
    opencode = {
      enable = true;
      theme = "tokyonight";
      mcps = [
        "coros"
      ];
      # mcp-atlassian does not build on x86_64-darwin with the pinned nixpkgs;
      # override with a no-op stub (jira is not in mcps anyway).
      mcp-atlassian-package = pkgs.writeShellScriptBin "mcp-atlassian" ''
        #!${pkgs.bash}
        echo "mcp-atlassian is not available on x86_64-darwin" >&2
        exit 1
      '';
      claudeAuth.enable = false;
    };
    claude-code = {
      enable = false;
    };
  };
  programs = {
    home-manager.enable = true;
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

  # Packages from nixpkgs — GUI apps are managed by Homebrew via nix-darwin.
  home.packages =
    with pkgs; [
      # This does not come installed by default on MacOS
      gcc
      sleepwatcher
    ];

  # Skip the nixpkgs release compatibility check — this config intentionally
  # uses a pinned (nixos-26.05) nixpkgs that will diverge from the flake's
  # primary input.  The check would always warn about the mismatch.
  home.enableNixpkgsReleaseCheck = false;
  home.sessionVariables = { };

  home.file.".wakeup" = {
    text = ''
      #!/bin/sh

      /usr/local/bin/voltageshift power 17 30
    '';
    executable = true;
  };

  launchd.enable = true;
  launchd.agents.sleepwatcher = {
    enable = true;
    config = {
      ProgramArguments = [
        "${lib.getExe pkgs.sleepwatcher}"
        "-w"
        "${config.home.homeDirectory}/.wakeup"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      Label = "com.massix.hackintosh.sleepwatcher";
    };
  };

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
      cores = 2;
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
}
