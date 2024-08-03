{
  description = "Elendil configuration via Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstablepkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    /* Warning: packages from this repo are subject to change rapidly!. */
    masterpkgs.url = "github:NixOS/nixpkgs/master";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "unstablepkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "unstablepkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    homeage.url = "github:jordanisaacs/homeage";
    homeage.inputs.nixpkgs.follows = "unstablepkgs";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "unstablepkgs";

    flake-compat.url = "github:inclyc/flake-compat";
    flake-compat.flake = false;

    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-direnv.inputs.nixpkgs.follows = "unstablepkgs";

    purescript-overlay.url = "github:thomashoneyman/purescript-overlay";
    purescript-overlay.inputs.nixpkgs.follows = "unstablepkgs";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "unstablepkgs";

    protrans.url = "github:massix/protrans";
    protrans.inputs.nixpkgs.follows = "unstablepkgs";
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
    , protrans
    , self
    , ...
    }:
    let
      system = "x86_64-linux";
      stateVersion = "24.05";
      overlays = [
        (_final: _prev: { nixd-nightly = nixd.packages."${system}".nixd; })
        (_final: _prev: self.packages."${system}")
        nix-direnv.overlays.default
        purescript-overlay.overlays.default
      ];

      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
        permittedInsecurePackages = [ "electron-25.9.0" ];
      };

      stable = import nixpkgs {
        inherit system overlays config;
      };

      unstable = import unstablepkgs {
        inherit system overlays config;
      };

      master = import masterpkgs {
        inherit system overlays config;
      };

      helpers = import ./lib {
        inherit home-manager homeage;
        nixpkgs = unstablepkgs;
      };

      username = "massi";
    in
    {
      nix.nixPath = [ "nixpkgs=${unstablepkgs}" ];

      homeConfigurations."massi@elendil" = helpers.mkHome {
        inherit stable stateVersion master username;
        pkgs = unstable;
        extraModules = [
          protrans.homeManagerModules.default
          ./home/elendil
        ];
      };

      nixosConfigurations."elendil" = helpers.mkSystem {
        inherit stable stateVersion system;
        pkgs = unstable;
        extraModules = [
          ./system/elendil/configuration.nix
          ./system/elendil/hardware-configuration.nix
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
        ];
      };

      packages."${system}" = import ./pkgs { pkgs = unstable; };

      devShells."${system}" = {
        default = unstable.mkShell {
          packages = with unstable; [
            deadnix /* dead code for nix */
            nixpkgs-fmt /* Formatter for nix */
            statix /* Static analyzer for nix */
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
        pkgs = stable;
        config.tools = {
          alejandra.enable = false;
          deadnix.enable = true;
          nixpkgs-fmt.enable = true;
          statix.enable = true;
        };
      };
    };
}
