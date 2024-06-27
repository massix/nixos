{ pkgs, config, lib, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.my-modules.coding;

  mkEnDef = description: default: mkOption {
    inherit description default;
    type = types.bool;
    example = true;
  };

in
{
  options.my-modules.coding = {
    enable = mkEnDef "Enable coding goodies" false;
    languages = {
      c = mkEnDef "Enable Clang tooling" false;
      c_sharp = mkEnDef "Enable C# tooling" false;
      go = mkEnDef "Enable Go tooling" false;
      haskell = mkEnDef "Enable Haskell tooling" false;
      java = mkEnDef "Enable Java tooling" false;
      javascript = mkEnDef "Enable Javascript tooling" false;
      json = mkEnDef "Enable JSON tooling" false;
      kotlin = mkEnDef "Enable Kotlin tooling" false;
      lua = mkEnDef "Enable LUA tooling" false;
      misc = mkEnDef "Enable other stuff (git, docker, ...)" false;
      nix = mkEnDef "Enable Nix tooling" false;
      purescript = mkEnDef "Enable Purescript tooling" false;
      racket = mkEnDef "Enable racket tooling" false;
      rust = mkEnDef "Enable Rust tooling" false;
      scripting = mkEnDef "Enable scripting tooling" false;
      terraform = mkEnDef "Enable Terraform tooling" false;
      yaml = mkEnDef "Enable YAML tooling" false;
      typst = mkEnDef "Enable Typst tooling" false;
    };
  };

  config =
    let
      whenT = k: t: if k then t else [ ];
      baseTooling = with pkgs; [
        gcc
        wl-clipboard
        nodejs
      ];

      clangTooling = with pkgs; [
        llvmPackages.clang-unwrapped
      ];

      c_sharpTooling = with pkgs; [
        omnisharp-roslyn
        netcoredbg
      ];

      goTooling = with pkgs; [
        gopls /* LSP */
        gofumpt /* Formatter */
        delve /* Debugger */
        golangci-lint /* Collection of linters */
      ];

      haskellTooling = with pkgs; [
        haskellPackages.ormolu /* Formatter */
        haskell-language-server /* LSP */

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

        haskellPackages.haskell-debug-adapter /* debugger for haskell */
        haskellPackages.haskell-dap /* dap interface for haskell */
        haskellPackages.ghci-dap /* dap interface for haskell-ghci */
        haskellPackages.hlint /* linter for haskell */

        /* Tools */
        haskellPackages.hoogle /* Hoogle search tool */
      ];

      purescriptTooling = with pkgs; [
        purs-tidy-bin.purs-tidy-0_10_0 /* Formatter for purescript */
        purescript-language-server /* language server for purescript */
      ];

      kotlinTooling = with pkgs; [
        kotlin-language-server
        ktlint /* linter for kotlin */
      ];

      racketTooling = with pkgs; [
        racket
      ];

      scriptingTooling = with pkgs; [
        nodePackages.bash-language-server /* language server for bash */
      ];

      nixTooling = with pkgs; [
        deadnix /* dead code for nix */
        nixpkgs-fmt /* Formatter for nix */
        statix /* Static analyzer for nix */
        nil /* language server for nix */
        nixd-nightly /* alternative language server for nix */
      ];

      terraformTooling = with pkgs; [
        tfsec /* Static analyzer for terraform */
        terraform-ls /* language server for terraform */
        trivy /* security scanner for terraform */
      ];

      javascriptTooling = with pkgs; [
        vscode-js-debug /* debugger for javascript */
        nodePackages_latest.typescript-language-server /* language server for typescript */
      ];

      luaTooling = with pkgs; [
        (stylua.override { features = [ "lua54" "luau" ]; }) /* Formatter for lua */
        lua-language-server /* language server for lua */
      ];

      rustTooling = with pkgs; [
        rust-analyzer /* language server for rust */
        cargo-nextest /* test runner for rust */
        rustfmt /* formatter for rust */
        vscode-extensions.vadimcn.vscode-lldb /* debugger for rust */
      ];

      javaTooling = with pkgs; [
        jdt-language-server /* language server for java */
        lombok /* lombok agent */
        google-java-format /* formatter for Java */
      ];

      jsonTooling = with pkgs; [
        vscode-langservers-extracted /* language server for json */
      ];

      yamlTooling = with pkgs; [
        yaml-language-server /* language server for yaml */
        yamllint /* linter for yaml */
        yamlfmt /* formatter for yaml */
      ];

      miscTooling = with pkgs; [
        dockerfile-language-server-nodejs /* language server for docker */
        helm-ls /* language server for helm */
        codeium-ls /* language server for codeium */
        gitlint /* linter for git commit messages */
        hadolint /* linter for Dockerfiles */
        marksman /* language server for markdown */
        commitlint /* linter for commit messages */
        actionlint /* linter for github actions */
        cocogitto /* autogenerate changelogs */
        dotenv-linter /* linter for dotenv files */
        editorconfig-checker /* linter for .editorconfig files */
        gnumake42 /* makefile */
        bear /* generate compilation database */
      ];

      typstTooling = with pkgs; [
        typst-lsp /* lsp for typst */
        typstfmt /* experimental formatter for typst */
      ];
    in
    {
      home.packages =
        baseTooling ++
        (whenT cfg.languages.c clangTooling) ++
        (whenT cfg.languages.c_sharp c_sharpTooling) ++
        (whenT cfg.languages.go goTooling) ++
        (whenT cfg.languages.haskell haskellTooling) ++
        (whenT cfg.languages.purescript purescriptTooling) ++
        (whenT cfg.languages.racket racketTooling) ++
        (whenT cfg.languages.nix nixTooling) ++
        (whenT cfg.languages.terraform terraformTooling) ++
        (whenT cfg.languages.kotlin kotlinTooling) ++
        (whenT cfg.languages.javascript javascriptTooling) ++
        (whenT cfg.languages.lua luaTooling) ++
        (whenT cfg.languages.rust rustTooling) ++
        (whenT cfg.languages.java javaTooling) ++
        (whenT cfg.languages.json jsonTooling) ++
        (whenT cfg.languages.yaml yamlTooling) ++
        (whenT cfg.languages.scripting scriptingTooling) ++
        (whenT cfg.languages.misc miscTooling) ++
        (whenT cfg.languages.typst typstTooling);
    };
}
