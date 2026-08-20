{ pkgs
, config
, username
, ...
}:
let
  inherit (config.home) homeDirectory;
in
{
  massix = {
    firefox.enable = false;
    devops.enable = false;
    claude-code.enable = false;

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
        drs = "sudo darwin-rebuild switch";
      };
    };
    git = {
      enable = true;
      workRepository.enabled = false;
    };
    opencode = {
      enable = true;
      theme = "tokyonight";
      mcps = [
        "coros"
      ];
      claudeAuth.enable = false;
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
    mpv.enable = true;
  };

  # Packages from nixpkgs — GUI apps are managed by Homebrew via nix-darwin.
  home.packages =
    with pkgs; [
      # This does not come installed by default on MacOS
      gcc
    ];

  home.sessionVariables = { };

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
