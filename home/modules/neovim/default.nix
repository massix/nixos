{ config, lib, pkgs, unstable, ... }:
let
  cfg = config.my-modules.neovim;
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) buildNpmPackage;

  # Codeium Language Server
  codeium-ls = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "codeium-ls";
    version = "1.2.90";

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];

    src = builtins.fetchurl {
      url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${version}/language_server_linux_x64.gz";
      sha256 = "sha256:0mb1b9jflzhr40n2zhmd4d1s9n1siq89bghn295arhl7grk41mwy";
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
    version = "1.83.0";

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
      hash = "sha256-a8Ih58EAL7YlKAXG8XigfCbLmvQh7aI2GLuS2VI1WC8=";
    };

    npmDepsHash = "sha256-FcHgCcw638Xqi+FeIIpbVnv4AFmL7Nad4TwMEprQq3k=";

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
            # NIX
            deadnix /* dead code for nix */
            nixpkgs-fmt /* Formatter for nix */
            statix /* Static analyzer for nix */
            nil /* language server for nix */

            # LUA
            stylua /* Formatter for lua */
            lua-language-server /* language server for lua */

            terraform-ls /* language server for terraform */
            jdt-language-server /* language server for java */
            vscode-langservers-extracted /* language server for json */
            dockerfile-language-server-nodejs /* language server for docker */
            yaml-language-server /* language server for yaml */
            helm-ls /* language server for helm */
            nodePackages_latest.typescript-language-server /* language server for typescript */
            codeium-ls /* language server for codeium */
            vscode-js-debug /* language server for javascript */
            rust-analyzer /* language server for rust */
            cargo-nextest /* test runner for rust */
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
            codeiumLs = "${codeium-ls}/bin/codeium-ls_server_linux_x64",
            vsCodeJsDebug = "${vscode-js-debug}/vscode-js-debug",
            nodePath = "${pkgs.nodejs}/bin/node",
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
      };

    home.sessionVariables = mkIf cfg.defaultEditor {
      EMACS = "${config.programs.neovim.finalPackage}/bin/nvim";
      EDITOR = "nvim";
    };
  };
}
