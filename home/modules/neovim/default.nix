{ config, lib, unstable, master, username, ... }:
let
  cfg = config.my-modules.neovim;
  inherit (unstable) rustPlatform fetchFromGitHub;
  inherit (lib) mkEnableOption mkPackageOption mkIf mkOption types;
  mkStringOption = description: default: mkOption {
    type = types.str;
    inherit default description;
  };
  mkIntOption = description: default: mkOption {
    type = types.number;
    inherit default description;
  };
  nvimLangs = map
    ({ code, hash }: unstable.stdenvNoCC.mkDerivation rec {
      pname = "neovim-spell-${code}";
      version = "1.0.0";
      spellFile = "${code}.utf-8.spl";
      src = unstable.fetchurl {
        url = "http://ftp.vim.org/pub/vim/runtime/spell/${spellFile}";
        inherit hash;
      };

      dontBuild = true;
      dontConfigure = true;
      dontPatch = true;
      dontUnpack = true;

      installPhase = ''
        mkdir -p $out/spell
        cp $src $out/spell/${spellFile}
      '';
    }) [{ code = "it"; hash = "sha256-2AczkD6DbVN5DAq4wcLyn2Y8oqd67ns4Guprh2KudBM="; }
    { code = "fr"; hash = "sha256-q/uXArmNiHwXWs5Y8as5cz3AjQO2dNkU9WNE74bmO2E="; }
    { code = "en"; hash = "sha256-/sq9yUm2o50ywImfolReqyXmPy7QozxK0VEUJjhNMHA="; }];
  sniprun = rustPlatform.buildRustPackage rec {
    pname = "sniprun";
    version = "1.3.11";

    src = fetchFromGitHub {
      owner = "michaelb";
      repo = "sniprun";
      sha256 = "sha256-f/EifFvlHr41wP0FfkwSGVdXLyz739st/XtnsSbzNT4=";
      rev = "v${version}";
    };

    cargoSha256 = "sha256-ntOlz0jP5csVQnopu2BixXuVSFCFI7pwqG+H8hCu0dA=";
    doCheck = false;
  };
in
{
  options.my-modules.neovim = {
    enable = mkEnableOption "Enable neovim handling";
    defaultEditor = mkEnableOption "Use nvim as default editor";
    configuration = {
      package = mkPackageOption unstable "neovim" {
        default = "neovim-unwrapped";
      };
      unstable = mkEnableOption "Install from the unstable channel";
      nightly = mkEnableOption "Install from the nightly channel";
    };
    gui = {
      enable = mkEnableOption "Install GUI";
      package = mkPackageOption unstable "neovide" {
        default = "neovide";
      };
      font = {
        name = mkStringOption "Font" "FiraCode";
        size = mkIntOption "Font Size" 10;
      };
      scaleFactor = mkIntOption "Scale Factor" 1.0;
    };
  };

  config = {
    programs.neovim = mkIf cfg.enable {
      inherit (cfg) enable defaultEditor;
      inherit (cfg.configuration) package;

      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
      extraLuaPackages = ps: [ ps.magick ];
    };

    home.packages = mkIf cfg.gui.enable [ cfg.gui.package ];

    # Link needed files, we cannot link the whole directory or lazyVim won't work
    home.file =
      let
        nvimHome = ".config/nvim";
        plugins = "${nvimHome}/lua/plugins";
        config = "${nvimHome}/lua/config";
        util = "${nvimHome}/lua/util";
        spell = "${nvimHome}/spell";

        # NOTE: "wonderful" hack to install the languages, still not sure if this is the best idea
        retrieveLang = lang: lib.head (lib.filter (drv: drv.spellFile == "${lang}.utf-8.spl") nvimLangs);
        langFiles = map
          (l: {
            name = "${spell}/${l}.utf-8.spl";
            value = {
              source = "${retrieveLang l}/spell/${l}.utf-8.spl";
            };
          }) [ "it" "en" "fr" ];
        mkGuiFont = font: size: "${builtins.replaceStrings [" "] ["_"] font},Symbols_Nerd_Font_Mono:h${builtins.toString size}";
      in
      {
        # Misc files
        "${util}/nix.lua".text = ''
          -- Some variables that are injected automatically by nix
          local bundles = {}

          table.insert(bundles, vim.fn.glob("${unstable.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft*.java"))
          vim.list_extend(
            bundles,
            vim.split(vim.fn.glob("${unstable.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar"), "\n")
          )

          return {
            nvimHome = "${nvimHome}",
            dapConfigured = true,
            jdtls = { bundles = bundles },
            codeium = "${unstable.codeium-ls}/bin/codeium-ls_server_linux_x64",
            vsCodeJsDebug = "${unstable.vscode-js-debug}/vscode-js-debug",
            nodePath = "${unstable.nodejs}/bin/node",
            rustDebugger = "${master.vscode-extensions.vadimcn.vscode-lldb}",
            rustWrapper = "/home/${username}/${nvimHome}/lldb-wrapper.sh",
            sniprun = "${sniprun}/bin/sniprun",
          }
        '';

        "${util}/defaults.lua".source = ./files/util/defaults.lua;

        # Init and start-up options
        "${nvimHome}/init.lua".source = ./files/init.lua;
        "${config}/options.lua".source = ./files/config/options.lua;
        "${config}/keymaps.lua".source = ./files/config/keymaps.lua;

        # The font is configurable via the configuration, so this is raw here
        "${config}/gui.lua".text = ''
          M = {}

          M.default_scale = ${toString cfg.gui.scaleFactor};

          M.change_scale_factor = function(delta)
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
          end

          M.setup = function()
            vim.o.guifont = "${mkGuiFont cfg.gui.font.name cfg.gui.font.size}"
            vim.g.neovide_floating_shadow = true
            vim.g.neovide_hide_mouse_when_typing = false
            vim.g.neovide_theme = "dark"
            vim.g.neovide_unlink_border_highlights = true
            vim.g.neovide_confirm_quit = false
            vim.g.neovide_cursor_antialiasing = true
            vim.g.neovide_scale_factor = M.default_scale

            -- Register keybinding to modify the scale
            require("which-key").register({
              ["<leader>+"] = {
                name = "+scale",
                ["+"] = { function() require("config.gui").change_scale_factor(1.25) end, "Increase scale" },
                ["-"] = { function() require("config.gui").change_scale_factor(1/1.25) end, "Decrease scale" },
              },
            })

            -- Also create some more immediate bindings
            vim.keymap.set("n", "<C-=>", function() require("config.gui").change_scale_factor(1.25) end, { desc = "Increase scale" })
            vim.keymap.set("n", "<C-->", function() require("config.gui").change_scale_factor(1/1.25) end, { desc = "Decrease scale" })
          end

          return M
        '';

        # Plugins configurations
        "${plugins}/colorscheme.lua".source = ./files/plugins/colorscheme.lua;
        "${plugins}/editor.lua".source = ./files/plugins/editor.lua;
        "${plugins}/git.lua".source = ./files/plugins/git.lua;
        "${plugins}/coding.lua".source = ./files/plugins/coding.lua;
        "${plugins}/alpha.lua".source = ./files/plugins/alpha.lua;
        "${plugins}/lualine.lua".source = ./files/plugins/lualine.lua;
        "${plugins}/ui.lua".source = ./files/plugins/ui.lua;
        "${plugins}/dap.lua".source = ./files/plugins/dap.lua;
        "${plugins}/neotest.lua".source = ./files/plugins/neotest.lua;
        "${plugins}/toggleterm.lua".source = ./files/plugins/toggleterm.lua;
        "${plugins}/hardtime.lua".source = ./files/plugins/hardtime.lua;
        "${plugins}/codeium.lua".source = ./files/plugins/codeium.lua;
        "${plugins}/rust.lua".source = ./files/plugins/rust.lua;
        "${plugins}/purescript.lua".source = ./files/plugins/purescript.lua;
        "${plugins}/haskell.lua".source = ./files/plugins/haskell.lua;
        "${plugins}/iron.lua".source = ./files/plugins/iron.lua;
        "${plugins}/obsidian.lua".source = ./files/plugins/obsidian.lua;
        "${plugins}/orgmode.lua".source = ./files/plugins/orgmode.lua;
        "${plugins}/pomodoro.lua".source = ./files/plugins/pomodoro.lua;
        "${plugins}/project.lua".source = ./files/plugins/project.lua;
        "${plugins}/rest.lua".source = ./files/plugins/rest.lua;

        /* For reasons I still do not know, I have to create a wrapper for the codelldb extension to work, probably it's the env */
        "${nvimHome}/lldb-wrapper.sh" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            exec ${master.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
          '';
        };
      } // (lib.listToAttrs langFiles);

    home.sessionVariables = mkIf cfg.defaultEditor {
      EDITOR = "nvim";
    };


    xdg.configFile = mkIf cfg.gui.enable {
      "neovide/config.toml".text = ''
        [font]
        normal = ["${cfg.gui.font.name}"]
        size = ${builtins.toString cfg.gui.font.size}
      '';
    };

  };
}
