{
  lib,
  pkgs,
  ...
}:
let
  yamlGenerator = lib.generators.toYAML { };

  # clojure-lsp and cljfmt are GraalVM native-image builds and clj-kondo is a
  # Go build; nixpkgs does not provide them for x86_64-darwin, so each is only
  # installed where available (curunir is x86_64-darwin and built in CI).
  language-servers =
    with pkgs;
    [
      ansible-language-server
      gleam
      gopls
      bash-language-server
      fish-lsp
      nixd
      terraform-ls
      typescript-language-server
      lua-language-server
      vscode-langservers-extracted
      dockerfile-language-server
      helm-ls
      nginx-language-server
      tinymist
      yaml-language-server
      gitlab-ci-ls
      pyright
      nushell
    ]
    ++ lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.clojure-lsp) pkgs.clojure-lsp;

  formatters =
    with pkgs;
    [
      gofumpt
      deadnix
      nixfmt
      prettier
      (stylua.override {
        features = [
          "lua54"
          "luau"
        ];
      })
      yamlfmt
      typstyle
      ruff
      shellcheck
    ]
    ++ lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.cljfmt) pkgs.cljfmt;

  linters =
    with pkgs;
    [
      ansible-lint
      golangci-lint
      statix
      lua54Packages.luacheck
      yamllint
      hadolint
      commitlint
      actionlint
      dotenv-linter
      editorconfig-checker
      pylint
    ]
    ++ lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.clj-kondo) pkgs.clj-kondo;

  misc = with pkgs; [
    # NOTE: gcc is needed for Treesitter
    gcc
    nodejs
    delve # Debugger for Golang
    tfsec # Static analyzer for Terraform
    trivy # Security scanner for Terraform
    vscode-js-debug

    # Python base tooling
    python3
  ];
in
{
  home.packages = language-servers ++ formatters ++ linters ++ misc;

  # Default configuration for yamllint
  xdg.configFile."yamllint/config".text = yamlGenerator {
    extends = "default";
    rules = {
      anchors = "disable";
      line-length = "disable";
      document-start = "disable";
      document-end = "disable";
    };
  };

  # Default configuration for yamlfmt
  xdg.configFile."yamlfmt/yamlfmt.yaml".text = yamlGenerator {
    formatter = {
      type = "basic";
      include_document_start = false;
      line_ending = "lf";
      retain_line_breaks = true;
      scan_folded_as_literal = true;
      drop_merge_tag = true;
      disallow_anchors = false;
      eof_newline = true;
      trim_trailing_whitespace = true;
    };
  };
}
