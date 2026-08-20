# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a personal Nix **Flake** managing NixOS + macOS machines with Home Manager.
`trunk` is the main branch (not `main`/`master`).

## Machines

- **elendil** — NixOS on a Microsoft Surface Pro (`x86_64-linux`): a NixOS
  *system* config plus a home config. Uses a custom Zen + linux-surface kernel
  from `pkgs/kernel/`.
- **mgengarelli** — macOS (`aarch64-darwin`): **Home Manager + nix-darwin**
  (`darwinConfigurations.work-darwin`, `system/work-darwin/`). Homebrew (via
  nix-darwin) manages GUI apps; agenix decrypts a system-level secret (Cloudflare
  CA cert) at activation, separate from the home-manager-level `homeage` pipeline.
- **massi@mithrandir** — macOS (`aarch64-darwin`): **Home Manager + nix-darwin**
  (`darwinConfigurations.mithrandir`, `system/mithrandir/`). Homebrew (via
  nix-darwin) manages GUI apps. CLI tools and dotfiles via Home Manager.
- **mgengarelli@curunir** — macOS (`x86_64-darwin`) on a Surface Laptop 3
  running OpenCore. **Home Manager + nix-darwin** (Homebrew for GUI apps).
  Uses a pinned nixpkgs (`nixos-26.05`) because nixpkgs dropped
  `x86_64-darwin` support after that release. Overlays are disabled
  (`pkgSet pinned "x86_64-darwin" false`) — see `flake.nix`.

State version: `24.05`. Systems: `x86_64-linux`, `aarch64-darwin`, `x86_64-darwin`.

## Commands

```bash
# Lint (statix + deadnix + luacheck over neovim lua)
just lint
# Format nix + lua; or check without writing
just format
just check-format

# Validate ALL configs — REQUIRED after any .nix change
nix flake check --all-systems
nix flake show                 # list every configuration/output

# Build (does not apply)
nix build ".#homeConfigurations.mgengarelli.activationPackage"          # macOS home
nix build ".#homeConfigurations.\"massi@elendil\".activationPackage"    # linux home
nix build ".#nixosConfigurations.elendil.config.system.build.toplevel"  # NixOS system
nix build ".#darwinConfigurations.work-darwin.config.system.build.toplevel"  # macOS system (work)
nix build ".#darwinConfigurations.mithrandir.config.system.build.toplevel"  # macOS system (mithrandir)

# Apply (only with explicit authorization — see rules below)
home-manager switch                         # home configs
nixos-rebuild switch --flake .#elendil      # NixOS system

# Debug an evaluated value
nix eval --raw '.#homeConfigurations.mgengarelli.config.<attr>'
```

`direnv` (`.envrc` = `use flake`) loads the devShell with all linters and
language servers. There is no unit-test suite — `nix flake check` is the test.

## Rules

- **Run `nix flake check --all-systems` after editing any `.nix` file** — it
  catches errors before a build.
- **Never** run `nixos-rebuild`/`home-manager switch`, `git commit`, or
  `git push` without explicit authorization. Present a plan and wait for sign-off.
- If asked to make changes while on `trunk`, **propose creating and switching to
  a branch first**.
- **Planning-first**: analyze → draft a task list → present it → execute only
  after sign-off.
- **Be direct**: don't be sycophantic ("Excellent idea!"). Challenge weak
  requests and push toward productive brainstorming during planning.
- **Secrets**: never log or expose `.age` contents, keys, or tokens; treat
  `.env`, `*.key`, `*.pem`, `secrets/*` as off-limits.

## Architecture (the big picture)

### Evaluation flow — `flake.nix`
A per-system bundle is built by `pkgSet system` (`config` + the **overlay
list** + the resulting `pkgs` + `helpers` imported from `lib/`). Outputs are then
assembled:
- `darwinSet` → `homeConfigurations."mgengarelli"` (extraModule `./home/work-darwin`)
  and `darwinConfigurations.work-darwin` (agenix + `./system/work-darwin`)
- `hackintoshSet` → `homeConfigurations."mgengarelli@curunir"` (extraModule `./home/curunir`)
  and `darwinConfigurations.curunir` (nix-darwin + Homebrew)
- `linuxSet` → `nixosConfigurations."elendil"` + `homeConfigurations."massi@elendil"` (extraModule `./home/elendil`)
- `commonStuff` (via `flake-utils`) → `devShells.default` and `packages` (from `pkgs/`).

### `lib/default.nix` — `mkHome` / `mkSystem`
Every configuration goes through one of these two factory functions.
- `mkHome` injects a **base module list** shared by both home configs
  (`secrets`, `neovim`, `fish.nix`, `fonts.nix`, `git.nix`, `devops.nix`,
  `firefox.nix`, `ghostty.nix`, `opencode`, `claude-code`), then appends per-host
  `extraModules`. **To add a home module globally, add it to this list.** It also
  sets home-level `nix`/`homeage`/`home` defaults and an `nvd diff` activation report.
- `mkSystem` wraps `nixpkgs.lib.nixosSystem` with shared `nix` GC/cache settings.

### The `massix.*` module convention
Each module in `home/modules/` defines options under `options.massix.<name>`
(an `enable = mkEnableOption` plus settings) and gates everything behind
`config = mkIf cfg.enable {...}`. The base list in `lib/` *imports* modules;
the host entrypoints — `home/work-darwin/default.nix` (macOS work),
`home/mithrandir/default.nix` (macOS mithrandir), `home/curunir/default.nix`
(macOS curunir), and `home/elendil/default.nix` (Linux) — *enable & configure*
them via the `massix.<name>` namespace.

### Secrets pipeline (`homeage` + fish)
Secrets are age-encrypted `.age` files decrypted at activation by **homeage**
(configured in `lib/default.nix`; identity at `~/.age/key.txt`, mount differs
darwin vs linux). A module declares
`homeage.file.<name> = { source = ./secrets/x.age; symlinks = [ "~/.x" ]; }`.
For values a program needs as an **environment variable** (e.g. MCP tokens),
`home/modules/fish.nix` `interactiveShellInit` reads the decrypted token files
and `set -gx`s them (`GH_MCP_TOKEN`, `GITLAB_MCP_TOKEN`, `JIRA_MCP_TOKEN`).
Consequently those MCP secrets exist only in an **interactive fish session**.

### AI assistant / MCP module pattern
`opencode`, `claude-code` (and the `gemini` placeholder) share a pattern: a
`massix.<tool>` module with an `mcps` enum option selecting from a catalogue of
MCP server definitions, filtered to the enabled ones and serialized to a
read-only JSON config. Secrets are emitted as `${ENV_VAR}` placeholders the tool
expands at launch — never inlined. The catalogue is duplicated per tool because
each tool's config schema differs.

Platform-specific packages that may not build everywhere (e.g. `mcp-atlassian`
on `x86_64-darwin`) are exposed as `mkPackageOption` so host configs can override
them with stubs. See `massix.opencode.mcp-atlassian-package` for an example.

`claude-code` is special in *how* it loads config: Claude Code mutates
`~/.claude.json` and `~/.claude/settings.json`, so neither can be a read-only
nix symlink. The module instead writes `~/.claude/mcp.json` +
`~/.claude/nix-settings.json` and wires them in through a **fish alias** that
runs `command claude --mcp-config … --settings …`
(`home/modules/claude-code/default.nix`).

### Neovim configuration (module loading + symlinking)
`home/modules/neovim/default.nix` is the module; it also `imports = [ ./languages ]`,
which contributes every LSP server / formatter / linter as `home.packages` plus
`yamllint`/`yamlfmt` config. Key mechanics:

- **The Lua config is NOT copied into the nix store.** Instead it is exposed via
  an **out-of-store symlink**: `~/.config/nvim/lua` →
  `${xdg.configHome}/nixos/home/modules/neovim/files/lua` (built with
  `config.lib.file.mkOutOfStoreSymlink` and the `mkAbsolutePath` helper). This
  assumes the repo is checked out at `~/.config/nixos`, and means **editing a
  `files/lua/massix/*.lua` file takes effect on the next nvim launch with no
  rebuild**. Only `lua/`, a generated `.luarc.json`, and the spell files are
  linked — deliberately *not* the whole `~/.config/nvim` dir (linking the whole
  dir breaks the plugin manager), so nvim keeps that dir writable.
- **Plugins are managed at runtime, not by Nix.** `programs.neovim.initLua`
  bootstraps `mini.nvim` by `git clone`ing it into
  `~/.local/share/nvim/site/pack/deps/start/mini.nvim` on first run, then uses
  `mini.deps` to manage the rest. Nix only provides the neovim package + system
  tools (tree-sitter, ripgrep, fzf, luarocks, clipboard, …).
- **Lua entry flow**: `initLua` → `require("massix.entrypoint").configure()`
  (`files/lua/massix/entrypoint/init.lua`). That pulls in the `massix` aggregator
  (`files/lua/massix/init.lua`) and runs three phases — synchronous
  options/keybindings/autocmds, then `MiniDeps.now(...)` for startup-critical
  plugins, then `MiniDeps.later(...)` for deferred ones. Each `massix.<feature>()`
  call maps to a `files/lua/massix/<feature>.lua` module.
- `.luarc.json` is **generated by Nix** (`generateLuarc`) so the Lua language
  server resolves the neovim runtime + plugin paths. Spell files (it/en/fr) are
  fetched as derivations and symlinked into `~/.config/nvim/spell`.

### Custom packages & overlays
`pkgs/` holds custom derivations (`kernel`, `tanzu`, `tridentctl`), exposed as
flake `packages` and re-injected as an overlay (`(_: _: self.packages.${system})`)
so they appear as `pkgs.<name>` everywhere. Other overlays in `flake.nix`: NUR,
ghostty, purescript, plus `overrideAttrs` workarounds (nushell/direnv
`doCheck = false`, a KDE `plasma-workspace` XDG_DATA_DIRS fix).

## Repository layout

```
flake.nix            # entry point: pkgSet, overlays, darwin/linux/common outputs
lib/                 # mkHome / mkSystem factories + shared utilities
pkgs/                # custom derivations (kernel, tanzu, tridentctl)
home/
  modules/           # massix.* home modules (neovim, fish, opencode, claude-code, ...)
  work-darwin/       # macOS (mgengarelli) host config
  mithrandir/        # macOS (massi@mithrandir) host config
  curunir/           # macOS (mgengarelli@curunir) host config
  elendil/           # linux (massi@elendil) host config
system/work-darwin/  # nix-darwin system config for mgengarelli (Homebrew + agenix)
system/mithrandir/   # nix-darwin system config for mithrandir (Homebrew)
system/elendil/      # NixOS system config for the Surface Pro
.github/workflows/   # CI
```

## Code style

- **Nix**: idiomatic — prefer `lib`/builtins/Nixpkgs functions and the module
  system over custom code; use `lib.mkIf`/`lib.mkMerge` over ad-hoc conditionals;
  keep functions pure. Format with `nixpkgs-fmt` (80 col). Files: `kebab-case.nix`.
- **Lua** (`home/modules/neovim/files/`): 2-space indent, 120 col, `snake_case`
  vars/functions, `PascalCase` modules, always `local` at module scope. Format
  with `stylua`; lint with `luacheck`. Files: `snake_case.lua`.
- **YAML**: 2-space indent; `yamlfmt`/`yamllint`; `actionlint` for workflows.
