nixpkgs_fmt := `which nixpkgs-fmt`
statix := `which statix`
nix := `which nix`
home_manager := `which home-manager`
stylua := `which stylua`

default: switch

@format:
  {{ nix }} fmt
  {{ stylua }} .

@switch:
  {{ home_manager }} switch

@build:
  {{ home_manager }} build
  echo "built result"

@clean:
  rm -f result
