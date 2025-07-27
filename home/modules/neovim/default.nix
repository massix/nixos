{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.my-modules.neovim;
  inherit (pkgs) rustPlatform fetchFromGitHub;
  inherit (lib) mkEnableOption mkPackageOption mkIf strings;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  nvimLangs = map
    ({ code, hash }: pkgs.stdenvNoCC.mkDerivation rec {
      pname = "neovim-spell-${code}";
      version = "1.0.0";
      spellFile = "${code}.utf-8.spl";
      src = pkgs.fetchurl {
        url = "https://ftp.nluug.nl/pub/vim/runtime/spell/${spellFile}";
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
    version = "1.3.17";

    src = fetchFromGitHub {
      owner = "michaelb";
      repo = "sniprun";
      sha256 = "sha256-o8U3GXg61dfEzQxrs9zCgRDWonhr628aSPd/l+HxS70=";
      rev = "v${version}";
    };

    cargoHash = "sha256-HLPTt0JCmCM4SRmP8o435ilM1yxoxpAnf8hg3+8C54I=";
    doCheck = false;
  };
  vscode-extension = pname: { version, hash }: pkgs.stdenvNoCC.mkDerivation {
    inherit version pname;

    nativeBuildInputs = with pkgs; [ unzip ];

    src = builtins.fetchurl {
      url = "https://openvsxorg.blob.core.windows.net/resources/vscjava/${pname}/${version}/vscjava.${pname}-${version}.vsix";
      sha256 = hash;
    };

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      mkdir tmp
      unzip -x $src -d tmp
    '';

    installPhase = ''
      mkdir -p $out/lib
      ls -l tmp/
      cp tmp/extension/server/*.jar $out/lib/
    '';
  };
  vscode-java-test = vscode-extension "vscode-java-test" { version = "0.41.1"; hash = "sha256:1hk4x08w8kv485kjwrygay04b9z7629gcv613dnv7m579i71wwl9"; };
  vscode-java-debug = vscode-extension "vscode-java-debug" { version = "0.58.0"; hash = "sha256:0wa40rhfhkxhql16whylar8ciagvlb8xg97fixb5wxwvggzc8x23"; };
  configPath = "${config.xdg.configHome}/nixos";
  modulePath = "home/modules/neovim";
  lldb-wrapper = pkgs.writeScriptBin "lldb-wrapper" ''
    #!${lib.getExe pkgs.bash}
    exec ${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"

  '';
  mkAbsolutePath = path: "${configPath}/${modulePath}/${strings.removePrefix "./" path}";
in
{
  imports = [ ./languages ];

  options.my-modules.neovim = {
    enable = mkEnableOption "Enable neovim handling";
    defaultEditor = mkEnableOption "Use nvim as default editor";
    configuration = {
      package = mkPackageOption pkgs "neovim" {
        default = "neovim-unwrapped";
      };
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

      extraLuaPackages = ps: [ ps.magick ];
    };

    # The extra packages are needed for luarocks
    home.packages = with pkgs; [
      lua5_1
      lua51Packages.luarocks
      readline
      python3

      # The following are needed by different plugins
      fzf
      ripgrep
      skim
      goose-cli

      # Needed for obsidian.nvim
      (if stdenv.hostPlatform.isDarwin then pngpaste else wl-clipboard)
    ];

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
      in
      {
        # Misc files
        "${util}/nix.lua".text = ''
          -- Some variables that are injected automatically by nix
          local bundles = {}
          local debug_bundles = vim.split(vim.fn.glob("${vscode-java-debug}/lib/*.jar"), "\n")
          local test_bundles = vim.split(vim.fn.glob("${vscode-java-test}/lib/*.jar"), "\n")

          vim.list_extend(bundles, debug_bundles)
          vim.list_extend(bundles, test_bundles)

          return {
            nvimHome = "${nvimHome}",
            dapConfigured = true,
            jdtls = {
              bundles = bundles,
              lombok = "${pkgs.lombok}/share/java/lombok.jar",
            },
            codeium = "${lib.getExe pkgs.codeium-ls}",
            vsCodeJsDebug = "${pkgs.vscode-js-debug}/vscode-js-debug",
            nodePath = "${lib.getExe pkgs.nodejs}",
            rustDebugger = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}",
            rustWrapper = "${lib.getExe lldb-wrapper}",
            sniprun = "${lib.getExe' sniprun "sniprun"}",
            flakePath = vim.fn.expand("~/.config/nixos"),
          }
        '';

        "${util}/defaults.lua".source = mkOutOfStoreSymlink (mkAbsolutePath "./files/util/defaults.lua");

        # Init and start-up options
        "${nvimHome}/init.lua".source = mkOutOfStoreSymlink (mkAbsolutePath "./files/init.lua");

        "${config}/options.lua".source = mkOutOfStoreSymlink (mkAbsolutePath "./files/config/options.lua");
        "${config}/keymaps.lua".source = mkOutOfStoreSymlink (mkAbsolutePath "./files/config/keymaps.lua");

        # Plugins configurations
        "${plugins}".source = mkOutOfStoreSymlink (mkAbsolutePath "./files/plugins");
      } // (lib.listToAttrs langFiles);

    home.sessionVariables = mkIf cfg.defaultEditor {
      EDITOR = "nvim";
    };
  };
}
