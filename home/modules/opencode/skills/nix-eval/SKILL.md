---
name: nix-eval
description: Evaluate Nix expressions and explore Nixpkgs attribute trees
---

# Nix Expression Evaluator

Use this skill when you need to:
- Evaluate Nix expressions
- Explore Nixpkgs attribute paths
- Query package metadata
- Understand attribute set structure

## Commands

Use `nix eval` with appropriate flags:
```bash
# Evaluate a simple expression
nix eval '1 + 2'

# Explore Nixpkgs (flake reference)
nix eval github:NixOS/nixpkgs --json | head -100
nix eval github:NixOS/nixpkgs#hello --json
nix eval github:NixOS/nixpkgs#python3Packages.requests --json

# Evaluate local flake expressions
nix eval .#packages.x86_64-linux.hello
nix eval .#nixosConfigurations.elendil.config.services.xserver.enable

# For local evaluation, add to flake outputs:
# packages.${system}.myPackage = ...

# Check NixOS options at https://search.nixos.org/options
```

## Tips

- Use `--json` flag for parseable output
- Use flake references: `github:owner/repo#attribute`
- For local flakes, use `.#attribute` from the project directory
- For NixOS options, search at https://search.nixos.org/options
