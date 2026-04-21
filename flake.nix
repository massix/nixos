{
  description = "My multisystem configuration using flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    homeage.url = "github:aarongpower/homeage";
    homeage.inputs.nixpkgs.follows = "nixpkgs";

    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-direnv.inputs.nixpkgs.follows = "nixpkgs";

    purescript-overlay.url = "github:thomashoneyman/purescript-overlay";
    purescript-overlay.inputs.nixpkgs.follows = "nixpkgs";

    protrans.url = "github:massix/protrans";
    protrans.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    ghostty.url = "github:ghostty-org/ghostty";
    ghostty.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ nixpkgs
    , nur
    , flake-utils
    , home-manager
    , nixos-hardware
    , homeage
    , nix-direnv
    , purescript-overlay
    , protrans
    , nixos-wsl
    , zen-browser
    , self
    , ghostty
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
          (_: _: self.packages."${system}")
          nix-direnv.overlays.default
          purescript-overlay.overlays.default
          ghostty.overlays.default
          (_: _: { zen-browser-beta = zen-browser.packages.${system}.beta; })
          (_: _: { zen-browser-twilight = zen-browser.packages.${system}.twilight; })
          nur.overlays.default
          (final: prev: {
            # Workaround for nushell test failures on macOS (PR #510439 in nixpkgs fixes this but not yet in nixos-unstable)
            nushell = prev.nushell.overrideAttrs (_: {
              doCheck = false;
            });
            kdePackages = prev.kdePackages.overrideScope (
              _: kdePrev: {
                plasma-workspace =
                  let
                    basePkg = kdePrev.plasma-workspace;
                    xdgdataPkg = final.stdenv.mkDerivation {
                      name = "${basePkg.name}-xdgdata";
                      buildInputs = [ basePkg ];
                      dontUnpack = true;
                      dontFixup = true;
                      dontWrapQtApps = true;
                      installPhase = ''
                        mkdir -p $out/share
                        ( IFS=:
                          for DIR in $XDG_DATA_DIRS; do
                            if [[ -d "$DIR" ]]; then
                              cp -r $DIR/. $out/share/
                              chmod -R u+w $out/share
                            fi
                          done
                        )
                      '';
                    };
                    # undo the XDG_DATA_DIRS injection that is usually done in the qt wrapper
                    # script and instead inject the path of the above helper package
                    derivedPkg = basePkg.overrideAttrs {
                      preFixup = ''
                        for index in "''${!qtWrapperArgs[@]}"; do
                          if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                            unset -v "qtWrapperArgs[$((index+0))]"
                            unset -v "qtWrapperArgs[$((index+1))]"
                            unset -v "qtWrapperArgs[$((index+2))]"
                            unset -v "qtWrapperArgs[$((index+3))]"
                          fi
                        done
                        qtWrapperArgs=("''${qtWrapperArgs[@]}")
                        qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xdgdataPkg}/share")
                        qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
                      '';
                    };
                  in
                  derivedPkg;
              }
            );
          })
        ];
        pkgs = import nixpkgs {
          inherit system config overlays;
        };
        helpers = import ./lib {
          inherit home-manager homeage nixpkgs;
        };
      };
      darwinSet = with pkgSet "aarch64-darwin"; {
        homeConfigurations."mgengarelli" = helpers.mkHome {
          inherit inputs stateVersion system pkgs;
          username = "mgengarelli";
          extraModules = [
            ./home/work-darwin
          ];
        };
      };
      linuxSet = with (pkgSet "x86_64-linux"); {
        nixosConfigurations = {
          "elendil" = helpers.mkSystem {
            inherit stateVersion system pkgs;
            extraModules = [
              ./system/elendil/configuration.nix
              ./system/elendil/hardware-configuration.nix
              ./system/elendil/hardware-extension.nix
              nixos-hardware.nixosModules.microsoft-surface-pro-intel
            ];
          };
          "aiwendil" = helpers.mkSystem {
            inherit stateVersion system pkgs;
            extraModules = [
              ./system/aiwendil/configuration.nix
              nixos-wsl.nixosModules.default
            ];
          };
        };
        homeConfigurations = {
          "massi@elendil" = helpers.mkHome {
            inherit inputs stateVersion system pkgs;
            username = "massi";
            extraModules = [
              protrans.homeManagerModules.default
              ./home/elendil
            ];
          };
          "massi@aiwendil" = helpers.mkHome {
            inherit inputs stateVersion system pkgs;
            username = "massi";
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
            purescript-overlay.overlays.default
          ];
          pkgs = import nixpkgs {
            inherit system config overlays;
          };

        in
        {
          # This is the DevShell used by this project
          devShells = {
            default = pkgs.mkShell {
              packages = with pkgs; [
                # Linters and formatters
                deadnix
                nixpkgs-fmt
                stylua
                statix
                luaPackages.luacheck
                yamllint
                yamlfmt
                actionlint

                # Language servers
                nixd
                lua-language-server
                bash-language-server
                yaml-language-server

                # Task runners
                just
              ];
            };
          };

          packages = import ./pkgs { inherit pkgs; };
        });
    in
    commonStuff //
    linuxSet //
    { homeConfigurations = linuxSet.homeConfigurations // darwinSet.homeConfigurations; };
}
