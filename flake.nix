{
  description = "Elendil configuration via Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    unstablepkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware?rev=cb4dc98f776ddb6af165e6f06b2902efe31ca67a";

    homeage.url = "github:jordanisaacs/homeage";
    homeage.inputs.nixpkgs.follows = "nixpkgs";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat.url = "github:inclyc/flake-compat";
    flake-compat.flake = false;

    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-direnv.inputs.nixpkgs.follows = "nixpkgs";
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
    , ...
    }:
    let
      system = "x86_64-linux";
      stateVersion = "23.05";
      mypkgs = import ./pkgs/default.nix { pkgs = unstable; };

      pkgsconfig = { allowUnfree = true; };
      pkgs = import nixpkgs {
        inherit system;
        config = pkgsconfig;
        overlays = [
          (_final: _prev: { nixd-nightly = nixd; })
          (_final: _prev: { inherit (mypkgs) lombok; })
          nix-direnv.overlay
        ];
      };

      unstable = import unstablepkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowUnfreePredicate = _: true;
        config.packageOverrides = pkgs: {
          teams-for-linux = pkgs.teams-for-linux.override { inherit (pkgs) pipewire; };
        };
        overlays = [
          (_final: _prev: { nixd-nightly = nixd.packages."${system}".nixd; })
          (_final: _prev: { inherit (mypkgs) lombok; })
          nix-direnv.overlay
        ];
      };

      helpers = import ./lib { inherit home-manager nixpkgs homeage; };
    in
    {
      homeConfigurations."massi@elendil" = helpers.mkHome {
        inherit pkgs unstable stateVersion;
        username = "massi";
        extraModules = [ ./home/elendil ];
      };

      homeConfigurations."massi@coravandil" = helpers.mkHome {
        inherit pkgs unstable stateVersion;
        username = "massi";
        extraModules = [ ./home/coravandil ];
      };

      nixosConfigurations."elendil" = helpers.mkSystem {
        inherit pkgs unstable stateVersion system;
        extraModules = [
          nixos-hardware.nixosModules.microsoft-surface-common
          ./system/elendil/configuration.nix
          ./system/elendil/hardware-configuration.nix
        ];
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
