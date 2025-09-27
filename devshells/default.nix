{ pkgs }:
with pkgs;
{
  go = mkShell {
    packages = [
      go
      gopls
      gofumpt
      delve
      golangci-lint
    ];
  };

  gleam = mkShell {
    packages = [
      gleam
      erlang
      rebar3
    ];
  };

  haskell =
    let
      hp = with haskellPackages; [
        ormolu
        ghcide
        haskell-debug-adapter
        haskell-dap
        ghci-dap
        hlint
        hoogle
      ];
    in
    mkShell {
      packages = [
        ghc
        cabal-install
        haskell-language-server
      ] ++ hp;
    };

  ansible = mkShell {
    packages = [
      ansible
      ansible-lint
      vscode-extensions.redhat.ansible
      yamlfmt
      yaml-language-server
    ];
  };

  c = mkShell {
    packages = [
      llvmPackages.clang-unwrapped
    ];
  };

  c-sharp = mkShell {
    packages = [
      dotnet-sdk
      omnisharp-roslyn
      netcoredbg
    ];
  };

  purescript = mkShell {
    packages = [
      # These are coming from the purescript-overlay
      spago-unstable
      purs
      purs-tidy-bin.purs-tidy-0_10_0
      purescript-language-server
      purescript
    ];
  };

  kotlin = mkShell {
    packages = [
      kotlin
      openjdk
      kotlin-language-server
      ktlint
    ];
  };

  nix = mkShell {
    packages = [
      nix
      deadnix
      nixpkgs-fmt
      statix
      nixd
    ];
  };

  terraform = mkShell {
    packages = [
      terraform
      tfsec
      terraform-ls
      trivy
    ];
  };

  javascript = mkShell {
    packages = [
      nodejs
      typescript
      vscode-js-debug
      nodePackages.typescript-language-server
    ];
  };

  lua = mkShell {
    packages = [
      lua
      lua-language-server
      stylua
      luaPackages.luacheck
    ];
  };

  rust = mkShell {
    packages = [
      rust-analyzer
      cargo-nextest
      rustfmt
      vscode-extensions.vadimcn.vscode-lldb
    ];
  };

  java = mkShell {
    packages = [
      openjdk
      jdt-language-server
      lombok
      google-java-format
    ];
  };

  ansible-development = pkgs.callPackage ./ansible-dev.nix { };

  # WARN: this shell is kind of redundant with my-modules.devops.
  devops-base = mkShell {
    packages = [
      actionlint
      bash-language-server
      cocogitto
      commitlint
      dockerfile-language-server
      dotenv-linter
      editorconfig-checker
      fish-lsp
      gnumake42
      hadolint
      helm-ls
      kubectl
      kubectl-klock
      kubectl-ktop
      kubectl-node-shell
      kubernetes-helm
      kustomize
      nginx-language-server
      vscode-langservers-extracted
      yamlfmt
      yaml-language-server
      yamllint
    ];
  };

  typst = mkShell {
    packages = [
      tinymist
      typstfmt
    ];
  };
}
