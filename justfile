nixpkgs_fmt := `command -v nixpkgs-fmt`
statix := `command -v statix`
stylua := `command -v stylua`
deadnix := `command -v deadnix`
luacheck := `command -v luacheck`

[private]
default:
  just -l

[doc("Run linters")]
lint:
  {{ statix }} check
  {{ deadnix }} -f
  {{ luacheck }} home/modules/neovim/files

[doc("Checks formatting of nix and lua files")]
check-format:
  {{ nixpkgs_fmt }} --check .
  {{ stylua }} --check home/modules/neovim/files

[doc("Reformats nix and lua files")]
format:
  {{ nixpkgs_fmt }} .
  {{ stylua }} .

