{ config, lib, unstable, master, username, ... }:
let
  cfg = config.my-modules.neovim;
  inherit (lib) mkEnableOption mkPackageOption mkIf;
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
    };


    # Link needed files, we cannot link the whole directory or lazyVim won't work
    home.file =
      let
        nvimHome = ".config/nvim";
        plugins = "${nvimHome}/lua/plugins";
        config = "${nvimHome}/lua/config";
        util = "${nvimHome}/lua/util";
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
          }
        '';

        "${util}/defaults.lua".source = ./files/util/defaults.lua;

        # Init and start-up options 
        "${nvimHome}/init.lua".source = ./files/init.lua;
        "${config}/options.lua".source = ./files/config/options.lua;
        "${config}/keymaps.lua".source = ./files/config/keymaps.lua;

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

        /* For reasons I still do not know, I have to create a wrapper for the codelldb extension to work, probably it's the env */
        "${nvimHome}/lldb-wrapper.sh" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            exec ${master.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
          '';
        };
      };

    home.sessionVariables = mkIf cfg.defaultEditor {
      EDITOR = "nvim";
    };
  };
}
