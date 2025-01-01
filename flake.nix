{
  description = "Elendil configuration via Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstablepkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    /* Warning: packages from this repo are subject to change rapidly!. */
    masterpkgs.url = "github:NixOS/nixpkgs/master";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "unstablepkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "unstablepkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    homeage.url = "github:aarongpower/homeage";
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

    gleeter.url = "github:massix/gleeter";
    gleeter.inputs.nixpkgs.follows = "unstablepkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl/main";
    nixos-wsl.inputs.nixpkgs.follows = "unstablepkgs";

    cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    cosmic.inputs.nixpkgs.follows = "unstablepkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "unstablepkgs";
  };

  outputs =
    { nixpkgs
    , flake-utils
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
    , nixos-wsl
    , cosmic
    , gleeter
    , zen-browser
    , self
    , ...
    }:
    let
      allSystems = [ "x86_64-linux" "aarch64-darwin" ];
      stateVersion = "24.05";
      pkgSet = system: rec {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
          permittedInsecurePackages = [ "electron-25.9.0" ];
        };
        overlays = [
          (_: _: { nixd-nightly = nixd.packages.${system}.nixd; })
          (_: _: self.packages."${system}")
          nix-direnv.overlays.default
          purescript-overlay.overlays.default
          (_: _: { gleeter = gleeter.packages.${system}.default; })
          (_: _: { zen-browser-beta = zen-browser.packages.${system}.beta; })
          (_: _: { zen-browser-twilight = zen-browser.packages.${system}.twilight; })
        ];
        unstable = import unstablepkgs {
          inherit system config overlays;
        };
        stable = import nixpkgs {
          inherit system config overlays;
        };
        master = import masterpkgs {
          inherit system config overlays;
        };
        helpers = import ./lib {
          inherit home-manager homeage;
          nixpkgs = unstablepkgs;
        };
      };
      darwinSet = with pkgSet "aarch64-darwin"; {
        homeConfigurations."mgengarelli" = helpers.mkHome {
          inherit stable stateVersion master system;
          username = "mgengarelli";
          pkgs = unstable;
          extraModules = [
            ./home/work-darwin
          ];
        };
      };
      linuxSet = with (pkgSet "x86_64-linux"); {
        nixosConfigurations = {
          "elendil" = helpers.mkSystem {
            inherit stable stateVersion system;
            pkgs = unstable;
            extraModules = [
              ./system/elendil/configuration.nix
              ./system/elendil/hardware-configuration.nix
              nixos-hardware.nixosModules.microsoft-surface-pro-intel
              cosmic.nixosModules.default
            ];
          };
          "aiwendil" = helpers.mkSystem {
            inherit stable stateVersion system;
            pkgs = unstable;
            extraModules = [
              ./system/aiwendil/configuration.nix
              nixos-wsl.nixosModules.default
            ];
          };
        };
        homeConfigurations = {
          "massi@elendil" = helpers.mkHome {
            inherit stable stateVersion master system;
            username = "massi";
            pkgs = unstable;
            extraModules = [
              protrans.homeManagerModules.default
              ./home/elendil
            ];
          };
          "massi@aiwendil" = helpers.mkHome {
            inherit stable stateVersion master system;
            username = "massi";
            pkgs = unstable;
            extraModules = [
              ./home/aiwendil
            ];
          };
        };
      };
      commonStuff = flake-utils.lib.eachSystem allSystems (system:
        let
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
            permittedInsecurePackages = [ "electron-25.9.0" ];
          };
          overlays = [
            (_: _: { nixd-nightly = nixd.packages.nixd; })
            (_: _: self.packages)
            nix-direnv.overlays.default
            purescript-overlay.overlays.default
            (_: _: { gleeter = gleeter.packages.default; })
          ];
          unstable = import unstablepkgs {
            inherit system config overlays;
          };
        in
        {
          devShells = {
            default = unstable.mkShell {
              packages = with unstable; [
                deadnix
                nixpkgs-fmt
                statix
              ];
            };
            purescript = unstable.mkShell {
              packages = with unstable; [
                spago-unstable
                purs
                nodejs
              ];
            };
            haskell = unstable.mkShell {
              packages = with unstable; [
                cabal-install
                ghc
                stack
              ];
            };
          };

          formatter = nix-formatter-pack.lib.mkFormatter {
            pkgs = unstable;
            config.tools = {
              alejandra.enable = false;
              deadnix.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;
            };
          };

          packages = import ./pkgs { pkgs = unstable; };
        });
    in
    commonStuff // linuxSet // { homeConfigurations = linuxSet.homeConfigurations // darwinSet.homeConfigurations; };
}

