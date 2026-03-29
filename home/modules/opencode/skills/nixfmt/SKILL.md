---
name: nixfmt
description: Format Nix files according to standard conventions
---

# Nix Formatter

Use this skill to format Nix files using nixfmt.

## Installation

```bash
# Via flake
nix profile install github:nmattia/nixfmt

# Or run without installing
nix run github:nmattia/nixfmt -- file.nix
```

## Usage

```bash
# Format a single file (prints to stdout)
nixfmt file.nix

# Format in-place
nixfmt --wc file.nix

# Check if files need formatting (exit 1 if they do)
nixfmt --check file.nix

# Format multiple files
nixfmt file1.nix file2.nix

# Format all nix files in current directory
nixfmt **/*.nix
```

## Conventions

- 2 space indentation
- No trailing whitespace
- Align `=` signs in attribute sets
- Sort imports alphabetically
- Put lambda arguments on same line as `{ ... }` ->
