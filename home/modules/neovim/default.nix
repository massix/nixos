{ config, lib, pkgs, unstable, ... }:
let
  cfg = config.my-modules.neovim;
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) fetchFromGitHub;

  lazyVim = pkgs.stdenvNoCC.mkDerivation {
    pname = "lazyvim";
    version = "6.4.0";

    src = fetchFromGitHub {
      owner = "LazyVim";
      repo = "starter";
      rev = "a13d5c90769ce6177d1e27b46efd967ed52c1d68";
      hash = "sha256-H3vY0srAREisQ4Sv4YGcRFbKKQQ+7XL3dyBl+nRKFwQ=";
    };

    dontUnpack = true;
    dontConfigure = true;
    dontPatch = true;

    installPhase = ''
      export NVIM_PATH="$out/.config/nvim/"
      mkdir -p $NVIM_PATH
      cp $src/init.lua $NVIM_PATH
      cp $src/stylua.toml $NVIM_PATH
      cp $src/.neoconf.json $NVIM_PATH
      cp -r $src/lua $NVIM_PATH
    '';
  };

  codeiumls = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "codeium-ls";
    version = "1.2.90";

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
    ];

    src = builtins.fetchurl {
      url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
      sha256 = "sha256:0mb1b9jflzhr40n2zhmd4d1s9n1siq89bghn295arhl7grk41mwy";
    };

    dontBuild = true;
    dontUnpack = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/bin
      gunzip -d -c -f $src > $out/bin/language_server_linux_x64
      chmod +x $out/bin/language_server_linux_x64
    '';
  };
in
{
  options.my-modules.neovim = {
    enable = mkEnableOption "Enable neovim handling";
    defaultEditor = mkEnableOption "Use nvim as default editor";
    configuration.unstable = mkEnableOption "Install from the unstable channel";
  };

  config = {
    programs.neovim = mkIf cfg.enable {
      inherit (cfg) enable defaultEditor;

      viAlias = true;
      vimAlias = true;
      package = if cfg.configuration.unstable then unstable.neovim-unwrapped else pkgs.neovim-unwrapped;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

    home.packages = with unstable; [
      stylua
      gcc
      wl-clipboard

      # Some common language servers I don't want to install through devShells
      lua-language-server
      yaml-language-server
      nodePackages.vscode-json-languageserver-bin
      nixd-nightly
    ];

    # Link needed files, we cannot link the whole directory or lazyVim won't work
    home.file = {
      # All files coming from LazyVim sources
      ".config/nvim/init.lua".source = "${lazyVim}/.config/nvim/init.lua";
      ".config/nvim/stylua.toml".source = "${lazyVim}/.config/nvim/stylua.toml";
      ".config/nvim/.neoconf.json".source = "${lazyVim}/.config/nvim/.neoconf.json";
      ".config/nvim/lua/lazyvim/config/lazy.lua".source = "${lazyVim}/.config/nvim/lua/lazyvim/config/lazy.lua";
      ".config/nvim/lua/plugins/example.lua".source = "${lazyVim}/.config/nvim/lua/plugins/example.lua";
      ".config/nvim/lua/config/lazy.lua".source = "${lazyVim}/.config/nvim/lua/config/lazy.lua";

      # Configure the colorscheme
      ".config/nvim/lua/plugins/colorscheme.lua".source = ./files/colorscheme.lua;

      # Configure NeoGit
      ".config/nvim/lua/plugins/neogit.lua".source = ./files/neogit.lua;

      # Disable Mason since it won't work on NixOS
      ".config/nvim/lua/plugins/disabled.lua".source = ./files/disabled.lua;

      # Activate extra plugins from Lazy
      ".config/nvim/lua/plugins/extras.lua".source = ./files/extras.lua;

      # Enable Codeium (experimental) - cannot be in a separate file
      ".config/nvim/lua/plugins/codeium.lua".text = ''
        -- Plugin for codeium
        return {
          {
            "Exafunction/codeium.nvim",
            dependencies = {
              "nvim-lua/plenary.nvim",
              "hrsh7th/nvim-cmp",
            },
            config = function()
              require("codeium").setup({
                tools = {
                  language_server = "${codeiumls}/bin/language_server_linux_x64",
                },
              })
            end,
          },

          -- Register Codeium as a trusted source
          {
            "hrsh7th/nvim-cmp",
            opts = function(_, opts)
              local cmp = require("cmp")
              opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "codeium" } }))
            end,
          },
        }
      '';

      # Use nil as language server for nix
      ".config/nvim/lua/plugins/nix.lua".source = ./files/nix.lua;

      # On NixOS, the vscode-json-languageserver is called simply json-languageserver
      ".config/nvim/lua/plugins/json_ls.lua".source = ./files/json_ls.lua;

      # Dart LS with default configuration
      ".config/nvim/lua/plugins/dart.lua".source = ./files/dart.lua;

    };

    home.sessionVariables = mkIf cfg.defaultEditor {
      EMACS = "${config.programs.neovim.finalPackage}/bin/nvim";
      EDITOR = "nvim";
    };
  };
}
