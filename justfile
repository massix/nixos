nixpkgs_fmt := `which nixpkgs-fmt`
statix := `which statix`
nix := `which nix`
nixosrb := `which nixos-rebuild`
nixch := `which nix-channel`
home_manager := `which home-manager`
stylua := `which stylua`

default: switch

@format:
  {{ nix }} fmt
  {{ stylua }} .

@system:
  sudo {{ nixch }} update nixos-unstable
  sudo {{ nixosrb }} switch --impure

@switch:
  {{ home_manager }} switch

@build:
  {{ home_manager }} build
  echo "built result"

@clean:
  rm -f result
