# Every command CI runs is a recipe here.
# Run `just` (or `just --list`) to see available recipes.

set shell := ["bash", "-euo", "pipefail", "-c"]

targets := """
elendil nixosConfigurations.elendil.config.system.build.toplevel
massi@elendil homeConfigurations."massi@elendil".activationPackage
work-darwin darwinConfigurations.work-darwin.config.system.build.toplevel
mgengarelli homeConfigurations.mgengarelli.activationPackage
mithrandir darwinConfigurations.mithrandir.config.system.build.toplevel
massi@mithrandir homeConfigurations."massi@mithrandir".activationPackage
curunir darwinConfigurations.curunir.config.system.build.toplevel
mgengarelli@curunir homeConfigurations."mgengarelli@curunir".activationPackage
"""

# Resolve a target name to its flake attribute path.
[private]
attr target:
    #!/usr/bin/env bash
    set -euo pipefail
    target={{ quote(target) }}
    attr=""
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      name="${line%% *}"
      val="${line#* }"
      if [[ "$name" == "$target" ]]; then
        attr="$val"
        break
      fi
    done <<< {{ quote(targets) }}
    if [[ -z "$attr" ]]; then
      echo "Unknown target: $target" >&2
      echo "Known targets:" >&2
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        echo "  ${line%% *}" >&2
      done <<< {{ quote(targets) }}
      exit 1
    fi
    printf '%s\n' "$attr"

[doc("List available recipes")]
[group("meta")]
default:
    just --list

[doc("Verify required tools are installed and print their versions")]
[group("meta")]
doctor:
    #!/usr/bin/env bash
    set -euo pipefail
    tools=(just nix statix deadnix stylua luacheck nixfmt actionlint yamllint yamlfmt nvd)
    missing=()
    for t in "${tools[@]}"; do
      if ! command -v "$t" >/dev/null 2>&1; then
        missing+=("$t")
      fi
    done
    if (( ${#missing[@]} > 0 )); then
      echo "Missing required tools: ${missing[*]}" >&2
      echo "Load the devShell first: 'direnv allow' (or 'nix develop')." >&2
      exit 1
    fi
    version_of() {
      local t="$1" out
      for flag in --version -V -v version; do
        out=$("$t" "$flag" 2>&1 | head -n 1) || true
        if [[ -n "$out" ]] && [[ "$out" != *"unexpected argument"* ]] && [[ "$out" != *"unrecognized"* ]] && [[ "$out" != *"Usage:"* ]] && [[ "$out" != *"error:"* ]]; then
          printf '%s\n' "$out"
          return 0
        fi
      done
      # Fallback: derive a version from the nix store path.
      local p
      p=$(command -v "$t")
      basename "$(dirname "$(dirname "$p")")" | sed -E 's/^[a-z0-9]+-//'
    }
    for t in "${tools[@]}"; do
      printf '%-12s ' "$t"
      version_of "$t"
    done

[doc("Run all linters")]
[group("lint")]
lint: lint-nix lint-lua lint-yaml lint-actions lint-just

[doc("Lint Nix files with statix and deadnix")]
[group("lint")]
lint-nix:
    statix check
    deadnix -f $(git ls-files '*.nix')

[doc("Lint Lua files with luacheck")]
[group("lint")]
lint-lua:
    luacheck $(git ls-files '*.lua')

[doc("Lint YAML files with yamllint")]
[group("lint")]
lint-yaml:
    yamllint -c .yamllint.yaml .github

[doc("Lint GitHub Actions workflows with actionlint")]
[group("lint")]
lint-actions:
    actionlint

[doc("Check justfile formatting")]
[group("lint")]
lint-just:
    just --fmt --check

[doc("Format all files")]
[group("format")]
format: format-nix format-lua format-yaml format-just

[doc("Format Nix files with nixfmt")]
[group("format")]
format-nix:
    nixfmt $(git ls-files '*.nix')

[doc("Format Lua files with stylua")]
[group("format")]
format-lua:
    stylua $(git ls-files '*.lua')

[doc("Format YAML files with yamlfmt")]
[group("format")]
format-yaml:
    yamlfmt .github && yamlfmt .yamllint.yaml

[doc("Format justfile")]
[group("format")]
format-just:
    just --fmt

[doc("Check formatting of all files")]
[group("format")]
check-format: check-format-nix check-format-lua check-format-yaml check-format-just

[doc("Check Nix formatting")]
[group("format")]
check-format-nix:
    nixfmt --check $(git ls-files '*.nix')

[doc("Check Lua formatting")]
[group("format")]
check-format-lua:
    stylua --check $(git ls-files '*.lua')

[doc("Check YAML formatting")]
[group("format")]
check-format-yaml:
    yamlfmt -lint .github && yamlfmt -lint .yamllint.yaml

[doc("Check justfile formatting")]
[group("format")]
check-format-just:
    just --fmt --check

[doc("Fast evaluation check for all systems")]
[group("check")]
check:
    nix flake check --no-build --all-systems

[doc("Build checks for the current system")]
[group("check")]
check-build:
    nix flake check

[doc("Show flake outputs")]
[group("check")]
show:
    nix flake show

alias check-all := check

[doc("Build a target configuration")]
[group("build")]
build target:
    #!/usr/bin/env bash
    set -euo pipefail
    target={{ quote(target) }}
    attr=$(just attr "$target")
    nix build --out-link "result-$target" ".#$attr"

[doc("Build every target (foreign systems need remote builders)")]
[group("build")]
build-all:
    #!/usr/bin/env bash
    set -euo pipefail
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      just build "${line%% *}"
    done <<< {{ quote(targets) }}

[doc("Print target to attribute table")]
[group("build")]
hosts:
    #!/usr/bin/env bash
    set -euo pipefail
    printf '%-22s %s\n' "TARGET" "FLAKE ATTRIBUTE"
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      printf '%-22s %s\n' "${line%% *}" "${line#* }"
    done <<< {{ quote(targets) }}

[confirm("This mutates the system. Continue?")]
[doc("Switch a system configuration")]
[group("host")]
switch target:
    #!/usr/bin/env bash
    set -euo pipefail
    target={{ quote(target) }}
    case "$target" in
      elendil|work-darwin|mithrandir|curunir) ;;
      *)
        echo "Not a system target: $target" >&2
        exit 1
        ;;
    esac
    if [[ "$(uname -s)" == "Darwin" ]]; then
      sudo darwin-rebuild switch --flake ".#$target"
    else
      sudo nixos-rebuild switch --flake ".#$target"
    fi

[confirm("This mutates the system. Continue?")]
[doc("Switch a Home Manager configuration")]
[group("host")]
switch-home name:
    #!/usr/bin/env bash
    set -euo pipefail
    name={{ quote(name) }}
    home-manager switch --flake ".#$name"
[doc("Diff current system against a built target")]
[group("host")]
diff target:
    #!/usr/bin/env bash
    set -euo pipefail
    target={{ quote(target) }}
    nvd diff /run/current-system "result-$target"

[confirm("This mutates the system. Continue?")]
[doc("Roll back the system configuration")]
[group("host")]
rollback:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "$(uname -s)" == "Darwin" ]]; then
      sudo darwin-rebuild rollback
    else
      sudo nixos-rebuild switch --rollback
    fi

[confirm("This mutates the system. Continue?")]
[doc("Garbage collect old generations")]
[group("host")]
gc:
    sudo nix-collect-garbage --delete-older-than 14d

[doc("Update flake inputs (empty = all)")]
[group("update")]
update input="":
    #!/usr/bin/env bash
    set -euo pipefail
    input={{ quote(input) }}
    if [[ -n "$input" ]]; then
      nix flake update "$input"
    else
      nix flake update
    fi

[doc("Update flake inputs then run checks")]
[group("update")]
upgrade: update
    just check

[doc("Run lint, check-format and check (mirrors CI minus per-OS builds)")]
[group("ci")]
ci: lint check-format check
