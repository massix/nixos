{
  description = "Elendil configuration via Flakes";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstablepkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    /* Warning: packages from this repo are subject to change rapidly!. */
    masterpkgs.url = "github:NixOS/nixpkgs/master";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware?rev=fb6af288f6cf0f00d3af60cf9d5110433b954565";

    homeage.url = "github:jordanisaacs/homeage";
    homeage.inputs.nixpkgs.follows = "nixpkgs";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "github:inclyc/flake-compat";
    flake-compat.flake = false;

    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-direnv.inputs.nixpkgs.follows = "nixpkgs";

    purescript-overlay.url = "github:thomashoneyman/purescript-overlay";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs =
    { nixpkgs
    , unstablepkgs
    , home-manager
    , nixos-hardware
    , nix-formatter-pack
    , homeage
    , nixd
    , nix-direnv
    , masterpkgs
    , purescript-overlay
    , neovim-nightly
    , emacs-overlay
    , ...
    }:
    let
      system = "x86_64-linux";
      stateVersion = "23.11";
      mypkgs = import ./pkgs/default.nix { pkgs = unstable; };
      overlays = [
        (_final: _prev: { nixd-nightly = nixd.packages."${system}".nixd; })
        (_final: _prev: {
          inherit (mypkgs) lombok codeium-ls vscode-js-debug;
        })
        nix-direnv.overlays.default
        purescript-overlay.overlays.default
        # neovim-nightly.overlays.default
        emacs-overlay.overlays.default
      ];

      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
        permittedInsecurePackages = [ "electron-25.9.0" ];
      };

      pkgs = import nixpkgs {
        inherit system overlays config;
      };

      unstable = import unstablepkgs {
        inherit system overlays config;
      };

      master = import masterpkgs {
        inherit system overlays config;
      };

      helpers = import ./lib { inherit home-manager nixpkgs homeage; };
    in
    {
      homeConfigurations."massi@elendil" = helpers.mkHome {
        inherit pkgs unstable stateVersion master;
        username = "massi";
        extraModules = [ ./home/elendil ];
      };

      homeConfigurations."massi@coravandil" = helpers.mkHome {
        inherit pkgs unstable stateVersion master;
        username = "massi";
        extraModules = [ ./home/coravandil ];
      };

      nixosConfigurations."elendil" = helpers.mkSystem {
        inherit pkgs unstable stateVersion system;
        extraModules = [
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          nixos-hardware.nixosModules.microsoft-surface-common
          ./system/elendil/configuration.nix
          ./system/elendil/hardware-configuration.nix
        ];
      };
      devShells."${system}" = {

        default = unstable.mkShell {
          packages = with unstable; [
            deadnix /* dead code for nix */
            nixpkgs-fmt /* Formatter for nix */
            statix /* Static analyzer for nix */
            stylua /* Formatter for lua */
            nil /* language server for nix */
            lua-language-server /* language server for lua */
            vscode-langservers-extracted /* language server for json */
            lua54Packages.luacheck /* linter for lua */
          ];
        };

        /* Useful shell to kickstart a new project */
        purescript = with unstable; mkShell {
          packages = [
            spago-unstable
            purs
            nodejs
          ];
        };

        /* Starter shell for haskell */
        haskell = with unstable; mkShell {
          packages = [
            cabal-install
            ghc
            stack
          ];
        };
      };

      formatter.${system} = nix-formatter-pack.lib.mkFormatter {
        inherit pkgs;
        config.tools = {
          alejandra.enable = false;
          deadnix.enable = true;
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
      };
    };
}
