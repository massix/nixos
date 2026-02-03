{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.my-modules.neovim;
  inherit (lib) mkEnableOption mkPackageOption mkIf strings;
  inherit (lib.generators) toJSON;
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
  configPath = "${config.xdg.configHome}/nixos";
  modulePath = "home/modules/neovim";
  mkAbsolutePath = path: "${configPath}/${modulePath}/${strings.removePrefix "./" path}";
  generateLuarc =
    let
      plugins = [
        "which-key.nvim"
        "nvim-lspconfig"
        "mini.icons"
        "slimline.nvim"
        "blink.cmp"
        "snacks.nvim"
      ];
      plugins-paths =
        (map (x: "~/.local/share/nvim/site/pack/deps/opt/${x}/lua") plugins) ++
        [ "~/.local/share/nvim/site/pack/deps/start/mini.nvim/lua" ];
    in
    neovim-package: toJSON { } {
      "$schema" = "https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json";
      "codeLens.enable" = true;
      "workspace.library" = [
        "${neovim-package}/share/nvim/runtime/lua"
        (toString ./files/lua)
      ] ++ plugins-paths;
      "diagnostics.global" = [ "vim" ];
    };
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

      extraLuaPackages = luaPackages: [ luaPackages.magick ];

      initLua =
        # lua
        ''
          -- Clone mini.nvim and use it
          local path_package = vim.fn.stdpath("data") .. "/site/"
          local mini_path = path_package .. "pack/deps/start/mini.nvim"

          ---@diagnostic disable-next-line: undefined-field
          if not vim.loop.fs_stat(mini_path) then
            vim.notify("Installing `mini.nvim`", vim.log.levels.INFO)
            local clone_cmd = { "git", "clone", "--filter=blob:none", "https://github.com/nvim-mini/mini.nvim", mini_path }
            vim.fn.system(clone_cmd)
            vim.cmd([[packadd mini.nvim | helptags ALL]])
            vim.notify("Installed `mini.nvim`", vim.log.levels.INFO)
          end

          require("mini.deps").setup({ path = { package = path_package } })

          -- This is the main entrypoint for the whole configuration (old init.lua)
          require("massix.entrypoint").configure()
        '';
    };

    # The extra packages are needed for luarocks
    home.packages = with pkgs; [
      git
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
        spell = "${nvimHome}/spell";

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
        "${nvimHome}/lua".source = mkOutOfStoreSymlink (mkAbsolutePath "./files/lua");
        "${nvimHome}/.luarc.json".text = generateLuarc cfg.configuration.package;
      } // (lib.listToAttrs langFiles);

    home.sessionVariables = mkIf cfg.defaultEditor {
      EDITOR = "nvim";
    };
  };
}
