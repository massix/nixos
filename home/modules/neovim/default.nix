{ config, lib, pkgs, unstable, master, username, ... }:
let
  cfg = config.my-modules.neovim;
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) buildNpmPackage;

  # Codeium Language Server
  codeium-ls = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "codeium-ls";
    version = "1.4.22";

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

    src = builtins.fetchurl {
      url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
      sha256 = "sha256:0sqj00if3d3n4yni9rfllszhfzczawv1d0yxxfkf2jvidj49wfwr";
    };

    dontBuild = true;
    dontUnpack = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/bin
      gunzip -d -c -f $src > $out/bin/codeium-ls_server_linux_x64
      chmod +x $out/bin/codeium-ls_server_linux_x64
    '';
  };
  vscode-js-debug = buildNpmPackage rec {
    pname = "vscode-js-debug";
    version = "1.85.0";

    nativeBuildInputs = with pkgs; [
      nodePackages.gulp-cli
      python311
      pkg-config
    ];

    buildInputs = with pkgs; [ libsecret ];

    patches = [ ./patches/patch-packages-json.patch ];

    src = pkgs.fetchFromGitHub {
      owner = "microsoft";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-mBXH3tqoiu3HIo1oZdQCD7Mq8Tvkt2DXfcoXb7KEgXE=";
    };

    npmDepsHash = "sha256-O2P+sHDjQm9bef4oUNBab0khTdR/nUDyhalSoxj0JL0=";

    dontNpmBuild = true;

    buildPhase = ''
      runHook preBuild
      gulp clean compile vsDebugServerBundle:webpack-bundle
      runHook postBuild
    '';

    npmInstallFlags = "--omit=dev";

    installPhase = ''
      mkdir $out
      mv dist $out/${pname}
    '';
  };
in
{
  options.my-modules.neovim = {
    enable = mkEnableOption "Enable neovim handling";
    defaultEditor = mkEnableOption "Use nvim as default editor";
    configuration.unstable = mkEnableOption "Install from the unstable channel";
    languages.java = mkEnableOption "Install the DAP and Test adapters for Java";
    languages.auto = mkEnableOption "Install the Language Servers automatically";
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

    home.packages =
      let
        basePackages = with unstable; [
          gcc
          wl-clipboard
          nodejs
        ];
        javaPackages =
          if cfg.languages.java then with unstable; [
            vscode-extensions.vscjava.vscode-java-debug
            vscode-extensions.vscjava.vscode-java-test
          ] else [ ];
        languageServers =
          if cfg.languages.auto then with unstable; [
            /* Formatters and analyzers */
            deadnix /* dead code for nix */
            nixpkgs-fmt /* Formatter for nix */
            statix /* Static analyzer for nix */
            stylua /* Formatter for lua */
            tfsec /* Static analyzer for terraform */
            purs-tidy-bin.purs-tidy-0_10_0 /* Formatter for purescript */
            haskellPackages.ormolu /* Formatter for haskell */

            /* Language servers */
            nil /* language server for nix */
            lua-language-server /* language server for lua */
            terraform-ls /* language server for terraform */
            jdt-language-server /* language server for java */
            vscode-langservers-extracted /* language server for json */
            dockerfile-language-server-nodejs /* language server for docker */
            yaml-language-server /* language server for yaml */
            helm-ls /* language server for helm */
            nodePackages_latest.typescript-language-server /* language server for typescript */
            codeium-ls /* language server for codeium */
            rust-analyzer /* language server for rust */
            purescript-language-server /* language server for purescript */
            haskell-language-server /* language server for haskell */

            /* Extensions for HLS */
            haskellPackages.ghcide
            haskellPackages.hls-eval-plugin
            haskellPackages.hls-class-plugin
            haskellPackages.hls-hlint-plugin
            haskellPackages.hls-cabal-plugin
            haskellPackages.hls-retrie-plugin
            haskellPackages.hls-rename-plugin
            haskellPackages.hls-ormolu-plugin
            haskellPackages.hls-pragmas-plugin
            haskellPackages.hls-refactor-plugin
            haskellPackages.hls-code-range-plugin
            haskellPackages.hls-module-name-plugin
            haskellPackages.hls-call-hierarchy-plugin
            haskellPackages.hls-explicit-fixity-plugin
            haskellPackages.hls-explicit-imports-plugin
            haskellPackages.hls-overloaded-record-dot-plugin
            haskellPackages.hls-qualify-imported-names-plugin
            haskellPackages.hls-explicit-record-fields-plugin

            /* Debuggers */
            vscode-js-debug /* debugger for javascript */
            master.vscode-extensions.vadimcn.vscode-lldb /* debugger for rust */
            haskellPackages.haskell-debug-adapter /* debugger for haskell */
            haskellPackages.haskell-dap /* dap interface for haskell */
            haskellPackages.ghci-dap /* dap interface for haskell-ghci */

            /* Test runners */
            cargo-nextest /* test runner for rust */

            /* Linters */
            gitlint /* linter for git commit messages */
            hadolint /* linter for Dockerfiles */

            /* Tools */
            haskellPackages.hoogle /* Hoogle search tool */
          ] else [ ];
      in
      basePackages ++ javaPackages ++ languageServers;

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

          ${if cfg.languages.java then ''
          table.insert(bundles, vim.fn.glob("${unstable.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft*.java"))
          vim.list_extend(
            bundles, 
            vim.split(vim.fn.glob("${unstable.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar"), "\n")
          )
          '' else "-- No bundles for DAP or test"}

          return {
            nvimHome = "${nvimHome}",
            dapConfigured = ${if cfg.languages.java then "true" else "false"},
            jdtls = { bundles = bundles },
            codeium = "${codeium-ls}/bin/codeium-ls_server_linux_x64",
            vsCodeJsDebug = "${vscode-js-debug}/vscode-js-debug",
            nodePath = "${pkgs.nodejs}/bin/node",
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
      EMACS = "${config.programs.neovim.finalPackage}/bin/nvim";
      EDITOR = "nvim";
    };
  };
}
