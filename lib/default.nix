{ home-manager
, nixpkgs
, homeage
, ...
}: {
  mkHome =
    { pkgs, unstable, stateVersion, username, extraModules ? [ ] }: home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit unstable stateVersion username; };

      modules = [
        homeage.homeManagerModules.homeage
        ../home/modules/base
        ../home/modules/helix.nix
        ../home/modules/fish.nix
        ../home/modules/fonts.nix
        ../home/modules/im.nix
        ../home/modules/git.nix
      ] ++ extraModules;
    };

  mkSystem =
    { pkgs, unstable, stateVersion, system, extraModules ? [ ] }:
    nixpkgs.lib.nixosSystem {
      inherit pkgs system;
      specialArgs = { inherit unstable stateVersion; };
      modules = [ ] ++ extraModules;
    };
}
