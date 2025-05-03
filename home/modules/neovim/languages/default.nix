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
    llvmPackages.clang-unwrapped
    omnisharp-roslyn
    gleam
    gopls
    haskell-language-server
    haskellPackages.ghcide
    bash-language-server
    fish-lsp
    nixd-nightly
    terraform-ls
    typescript-language-server
    lua-language-server
    vscode-langservers-extracted
    dockerfile-language-server-nodejs
    helm-ls
    codeium-ls
    nginx-language-server
    tinymist
    rust-analyzer
    purescript-language-server
  ];

  formatters = with pkgs; [
    gofumpt
    haskellPackages.ormolu
    deadnix
    nixpkgs-fmt
    nodePackages.prettier
    (stylua.override { features = [ "lua54" "luau" ]; })
    yamlfmt
    typstfmt
    rustfmt
  ];

  # INFO: ansible-lint does not currently compile on Darwin due to python3Packages.mocket
  linters = with pkgs; [
    golangci-lint
    haskellPackages.hlint
    statix
    lua54Packages.luacheck
    yamllint
    hadolint
    commitlint
    actionlint
    dotenv-linter
    editorconfig-checker
  ] ++ lib.optionals stdenv.isLinux [ ansible-lint ];

  misc = with pkgs; [
    gcc
    nodejs
    netcoredbg
    delve # Debugger for Golang
    haskellPackages.haskell-debug-adapter
    haskellPackages.haskell-dap
    haskellPackages.ghci-dap
    haskellPackages.hoogle
    tfsec # Static analyzer for Terraform
    trivy # Security scanner for Terraform
    vscode-js-debug
    vscode-extensions.vadimcn.vscode-lldb

    # Haskell base tooling.
    ghc
    cabal-install

    # Purescript base tooling
    spago-unstable
    purescript
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
      eof_newline = true;
    };
  };
}
