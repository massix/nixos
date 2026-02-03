{ lib
, pkgs
, ...
}:
let
  ansible-language-server-wrapper = pkgs.writeScriptBin "ansible-language-server" ''
    #!${lib.getExe pkgs.bash}

    exec ${lib.getExe pkgs.nodejs} ${pkgs.vscode-extensions.redhat.ansible}/share/vscode/extensions/redhat.ansible/out/server/src/server.js $*
  '';

  yamlGenerator = lib.generators.toYAML { };

  language-servers = with pkgs; [
    ansible-language-server-wrapper
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
  ];

  formatters = with pkgs; [
    gofumpt
    deadnix
    nixpkgs-fmt
    nodePackages.prettier
    (stylua.override { features = [ "lua54" "luau" ]; })
    yamlfmt
    typstyle
    ruff
    shellcheck
  ];

  linters = with pkgs; [
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
  ];

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
