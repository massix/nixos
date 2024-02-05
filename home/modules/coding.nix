{ pkgs, unstable, config, lib, master, ... }:
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
    unstable = mkEnDef "Use unstable channel" true;
    languages = {
      c_sharp = mkEnDef "Enable C# tooling" false;
      haskell = mkEnDef "Enable Haskell tooling" false;
      java = mkEnDef "Enable Java tooling" false;
      javascript = mkEnDef "Enable Javascript tooling" false;
      json = mkEnDef "Enable JSON tooling" false;
      lua = mkEnDef "Enable LUA tooling" false;
      misc = mkEnDef "Enable other stuff (git, docker, ...)" false;
      nix = mkEnDef "Enable Nix tooling" false;
      purescript = mkEnDef "Enable Purescript tooling" false;
      racket = mkEnDef "Enable racket tooling" false;
      rust = mkEnDef "Enable Rust tooling" false;
      terraform = mkEnDef "Enable Terraform tooling" false;
      yaml = mkEnDef "Enable YAML tooling" false;
    };
  };

  config =
    let
      channel = if cfg.unstable then unstable else pkgs;
      whenT = k: t: if k then t else [ ];
      baseTooling = with channel; [
        gcc
        wl-clipboard
        nodejs
      ];

      c_sharpTooling = with channel; [
        omnisharp-roslyn
        netcoredbg
      ];

      haskellTooling = with channel; [
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

      purescriptTooling = with channel; [
        purs-tidy-bin.purs-tidy-0_10_0 /* Formatter for purescript */
        purescript-language-server /* language server for purescript */
      ];

      racketTooling = with channel; [
        racket
      ];

      nixTooling = with channel; [
        deadnix /* dead code for nix */
        nixpkgs-fmt /* Formatter for nix */
        statix /* Static analyzer for nix */
        nil /* language server for nix */
      ];

      terraformTooling = with channel; [
        tfsec /* Static analyzer for terraform */
        terraform-ls /* language server for terraform */
      ];

      javascriptTooling = with channel; [
        vscode-js-debug /* debugger for javascript */
        nodePackages_latest.typescript-language-server /* language server for typescript */
      ];

      luaTooling = with channel; [
        stylua /* Formatter for lua */
        lua-language-server /* language server for lua */
      ];

      rustTooling = with channel; [
        rust-analyzer /* language server for rust */
        cargo-nextest /* test runner for rust */
      ] ++ [ master.vscode-extensions.vadimcn.vscode-lldb ];

      javaTooling = with channel; [
        jdt-language-server /* language server for java */
        vscode-extensions.vscjava.vscode-java-debug
        vscode-extensions.vscjava.vscode-java-test
        lombok /* lombok agent */
      ];

      jsonTooling = with channel; [
        vscode-langservers-extracted /* language server for json */
      ];

      yamlTooling = with channel; [
        yaml-language-server /* language server for yaml */
      ];

      miscTooling = with channel; [
        dockerfile-language-server-nodejs /* language server for docker */
        helm-ls /* language server for helm */
        codeium-ls /* language server for codeium */
        gitlint /* linter for git commit messages */
        hadolint /* linter for Dockerfiles */
        marksman /* language server for markdown */
        commitlint /* linter for commit messages */
      ];
    in
    {
      home.packages =
        baseTooling ++
        (whenT cfg.languages.c_sharp c_sharpTooling) ++
        (whenT cfg.languages.haskell haskellTooling) ++
        (whenT cfg.languages.purescript purescriptTooling) ++
        (whenT cfg.languages.racket racketTooling) ++
        (whenT cfg.languages.nix nixTooling) ++
        (whenT cfg.languages.terraform terraformTooling) ++
        (whenT cfg.languages.javascript javascriptTooling) ++
        (whenT cfg.languages.lua luaTooling) ++
        (whenT cfg.languages.rust rustTooling) ++
        (whenT cfg.languages.java javaTooling) ++
        (whenT cfg.languages.json jsonTooling) ++
        (whenT cfg.languages.yaml yamlTooling) ++
        (whenT cfg.languages.misc miscTooling);
    };
}
