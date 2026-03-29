---
name: nix-debug
description: Debug Nix evaluation errors and trace evaluation
---

# Nix Debugger

Use this skill when you encounter Nix evaluation errors.

## Common Error Patterns

### 1. Attribute set key errors
```
error: attribute 'foo' missing
```
- Use `nix eval <path> -A <attr> --json` to find available keys
- Check for typos in attribute names
- Some attributes may be conditional (wrapped in mkIf)

### 2. Function argument errors
```
error: anonymous function at ... called with unexpected argument 'x'
```
- Check the function's expected arguments
- Some functions require named arguments (args@{ ... })

### 3. Type errors
```
error: value is a string while a list was expected
```
- Use `lib.types` functions to validate types
- Wrap in `lib.mkIf` for conditional values

### 4. Infinite recursion
```
error: infinite recursion encountered
```
- Usually caused by referencing a variable before definition
- Check for circular dependencies in imports

## Debugging Techniques

```bash
# Dry run to see what would be built
nix build --dry-run

# Show the derivation
nix derivation show

# Trace evaluation
nix eval --expr 'builtins.trace "debug" expression'

# Check available options
nix eval github:NixOS/nixos-options#networking.hostName --json 2>/dev/null || echo "option not found"
```

## Useful Lib Functions

- `lib.genAttrs` - Generate attribute set from list
- `lib.mapAttrs` - Map over attribute set
- `lib.optional` - Conditionally include element
- `lib.optionals` - Conditionally include list
- `lib.foldl'` - Strict left fold
