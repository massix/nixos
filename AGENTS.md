# AGENTS.md - Agent Guidelines for This Repository

This repository contains NixOS/Nix-darwin system configurations managed with Flakes and Home Manager.

The "main" or "master" branch of this repository is called `trunk`.

## Build/Lint/Test Commands

### Linting
```bash
# Run all linters (statix, deadnix, luacheck)
just lint
```

### Formatting
```bash
# Check formatting without modifying
just check-format

# Auto-format files
just format
```

### Building & Testing Configurations

```bash
# Validate all systems (REQUIRED after any .nix modification)
nix flake check --all-systems

# Show all configurations
nix flake show

# Build specific system
nix build ".#nixosConfigurations.elendil.config.system.build.toplevel"

# Build specific home configuration
nix build ".#homeConfigurations.massi@elendil.activationPackage"
nix build ".#homeConfigurations.mgengarelli.activationPackage"

# Apply configuration (NixOS)
nixos-rebuild switch

# Apply configuration (macOS/darwin/elendil Home)
home-manager switch
```

Never launch **nixos-rebuild** or **home-manager** without explicit authorization.

## Code Style Guidelines

### Nix Style
- **Use idiomatic Nix**: Prefer built-in functions, `lib`, and Nixpkgs library functions over custom implementations
- **Avoid repetition**: Use imports, overlays, and modules to create reusable code
- **Module system**: Use Home Manager's module system (`home-manager/modules` style) for reusable configurations
- **Lazy evaluation**: Take advantage of Nix's lazy evaluation; avoid eager evaluation patterns
- **Pure functions**: Keep functions pure; avoid side effects
- **Type checking**: Use `nix eval --raw` to debug values; prefer explicit types for complex structures
- **Format**: Use `nixpkgs-fmt` (80-char line width default)

### Lua Style (Neovim Config)
- **Indent**: 2 spaces (no tabs)
- **Line width**: 120 characters max
- **Naming**: `snake_case` for variables/functions, `PascalCase` for modules/tables
- **Local scope**: Always use `local` for module-level definitions
- **Format**: Use `stylua` for auto-formatting

### YAML Style
- **Indent**: 2 spaces
- **Format**: Use `yamlfmt` for auto-formatting
- **Files**: GitHub workflows, actionlint config

### File Naming Conventions
- Nix files: `kebab-case.nix` (e.g., `home-manager.nix`)
- Lua files: `snake_case.lua` (e.g., `lsp_config.lua`)
- Configuration files: lowercase or kebab-case

## Key Rules

### 1. Always Use Idiomatic Nix
- Create reusable modules and libraries in `lib/`
- Use Nixpkgs overlays for custom packages
- Leverage Home Manager's module system
- Prefer built-in functions over custom implementations
- Example: Use `lib.mkIf`, `lib.mkMerge` instead of conditionals

### 2. Run Nix Flake Check After Modifications
**After ANY change to `.nix` files:**
```bash
nix flake check --all-systems
```
This validates all systems and catches errors before build.

### 3. Always propose to switch branches
If the user asks to do some changes while being on the `trunk` branch, always ask if you should
create and switch to a different branch instead.

### 4. Never Commit or Push Without Authorization
- Do not run `git commit` or `git push` unless explicitly authorized by user
- Present your plan first, wait for sign-off before executing

## Miscellaneous Rules

### Planning-First Principle
**Always follow this workflow:**
1. **Analyze** the request thoroughly
2. **Draft a plan** with a detailed task list
3. **Present the plan** to the user
4. **Execute** only after explicit sign-off

### Be Real
- Do not be overly nice with the user
- Do not say sentences like "Excellent idea!" when you do not really mean it
- Challenge the user's requests and force them into productive brainstorming when in planning phase


## Security

All agents must protect sensitive files:
- **Denied by default**: `.env`, `*.key`, `secrets/*`, `*.pem` files
- Never log or expose secrets, API keys, or credentials

## Repository Structure

```
.
├── flake.nix           # Main flake entry point
├── lib/                # Shared Nix utilities
├── pkgs/               # Custom package overlays
├── home/               # Home Manager modules
│   └── modules/        # Individual modules (neovim, fish, etc.)
├── system/             # NixOS system configurations
│   └── elendil/        # Surface Pro configuration
└── .github/workflows/  # CI/CD pipelines
```

## Quick Reference

| Task | Command |
|------|---------|
| Lint all | `just lint` |
| Format all | `just format` |
| Validate flake | `nix flake check` |
| Build elendil | `nix build ".#nixosConfigurations.elendil.config.system.build.toplevel"` |
| Apply elendil | `nixos-rebuild switch --flake .#elendil` |

## Notes

- This is a personal dotfiles repository - take inspiration but adapt for your own use
- State version: 24.05 (from `flake.nix`)
- Systems: x86_64-linux, aarch64-darwin
