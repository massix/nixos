{
  description = "My multisystem configuration using flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # x86_64-darwin support was removed from nixpkgs after the nixos-26.05
    # release.  The Hackintosh (Surface Laptop 3, OpenCore) still needs it, so
    # we pin to the last branch that includes the platform.  This input will
    # stop receiving security updates once nixos-26.05 goes EOL.
    pinned.url = "github:NixOS/nixpkgs/nixos-26.05";

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

    ghostty.url = "github:ghostty-org/ghostty";
    ghostty.inputs.nixpkgs.follows = "nixpkgs";

    hackintosh-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    hackintosh-darwin.inputs.nixpkgs.follows = "pinned";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.darwin.follows = "nixpkgs";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ nixpkgs
    , pinned
    , nur
    , flake-utils
    , home-manager
    , nixos-hardware
    , homeage
    , nix-direnv
    , purescript-overlay
    , protrans
    , self
    , ghostty
    , hackintosh-darwin
    , agenix
    , nix-darwin
    , ...
    }:
    let
      allSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      stateVersion = "24.05";
      pkgSet = base: system: withOverlays: rec {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
          permittedInsecurePackages = [ "electron-25.9.0" ];
          allowDeprecatedx86_64Darwin = system == "x86_64-darwin";
        };
        overlays =
          if withOverlays then [
            (_: _: self.packages."${system}")
            nix-direnv.overlays.default
            purescript-overlay.overlays.default
            ghostty.overlays.default
            nur.overlays.default
            (final: prev: {
              # Workaround for nushell test failures on macOS (PR #510439 in nixpkgs fixes this but not yet in nixos-unstable)
              nushell = prev.nushell.overrideAttrs (_: {
                doCheck = false;
              });
              # Workaround for direnv build failing on MacOS due to unlinked dependency with fish shell
              direnv = prev.direnv.overrideAttrs (_: {
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
          ] else [ ];
        pkgs = import base {
          inherit system config overlays;
        };
        helpers = import ./lib {
          inherit home-manager homeage nixpkgs;
        };
      };
      darwinSet = with (pkgSet nixpkgs "aarch64-darwin" true); {
        darwinConfigurations.mithrandir = nix-darwin.lib.darwinSystem {
          inherit system pkgs;
          modules = [
            ./system/mithrandir
          ];
        };
        darwinConfigurations.work-darwin = nix-darwin.lib.darwinSystem {
          inherit system pkgs;
          modules = [
            agenix.darwinModules.age
            ./system/work-darwin
          ];
        };
        homeConfigurations."massi@mithrandir" = helpers.mkHome {
          inherit inputs stateVersion system pkgs;
          username = "massi";
          extraModules = [
            ./home/mithrandir
          ];
        };
        homeConfigurations."mgengarelli" = helpers.mkHome {
          inherit inputs stateVersion system pkgs;
          username = "mgengarelli";
          extraModules = [
            ./home/work-darwin
          ];
        };
      };
      # Hackintosh: uses the pinned nixpkgs (x86_64-darwin) with overlays
      # disabled.  Overlays (NUR, ghostty, nix-direnv, purescript) reference
      # packages built against nixos-unstable and are ABI-incompatible with the
      # older pinned set.  GUI apps (Ghostty, Proton suite, etc.) are managed
      # by Homebrew via hackintoshDarwinSet; CLI tools stay in nixpkgs.
      hackintoshSet = with (pkgSet pinned "x86_64-darwin" false); {
        homeConfigurations."mgengarelli@curunir" = helpers.mkHome {
          inherit inputs stateVersion system pkgs;
          username = "mgengarelli";
          extraModules = [ ./home/curunir ];
        };
        darwinConfigurations.curunir = hackintosh-darwin.lib.darwinSystem {
          inherit system pkgs;
          modules = [ ./system/curunir ];
        };
      };
      linuxSet = with (pkgSet nixpkgs "x86_64-linux" true); {
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
          pkgs =
            # The devShell for x86_64-darwin also needs the pinned nixpkgs so
            # linters and language servers resolve against a package set that
            # actually contains x86_64-darwin builds.
            if system == "x86_64-darwin" then
              import pinned { inherit system config overlays; }
            else
              import nixpkgs { inherit system config overlays; };

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
    {
      darwinConfigurations =
        darwinSet.darwinConfigurations //
        hackintoshSet.darwinConfigurations;
    }
    //
    {
      homeConfigurations =
        linuxSet.homeConfigurations //
        darwinSet.homeConfigurations //
        hackintoshSet.homeConfigurations;
    };
}
