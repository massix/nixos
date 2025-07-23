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

  # FIXME: remove this once the patch reaches unstable
  gitlab-ci-ls = pkgs.rustPlatform.buildRustPackage rec {
    pname = "gitlab-ci-ls";
    version = "1.1.2";
    src = pkgs.fetchFromGitHub {
      owner = "alesbrelih";
      repo = "gitlab-ci-ls";
      rev = "${version}";
      hash = "sha256-0AVi/DyaWh+dCXm/jUf3M63KjobJWCCKHDvm1xGUzCw=";
    };

    useFetchCargoVendor = true;
    cargoHash = "sha256-3Ko+vf24dEfu+g4yGA5xY0R0TA9fSWuG398DxhHIVFU=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.openssl ];

    meta = with lib; {
      homepage = "https://github.com/alesbrelih/gitlab-ci-ls";
      description = "GitLab CI Language Server (gitlab-ci-ls)";
      license = licenses.mit;
      maintainers = with maintainers; [ ma27 ];
      platforms = platforms.unix;
      mainProgram = "gitlab-ci-ls";
    };
  };

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
    nixd
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
    yaml-language-server
    gitlab-ci-ls
    pyright
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
    ruff
  ];

  linters = with pkgs; [
    ansible-lint
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
    pylint
  ];

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
