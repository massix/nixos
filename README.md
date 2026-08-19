# NixOS Configuration

A personal NixOS configuration repository managed with **Flakes** and **Home Manager**. Yes, another dotfiles repo — but at least this one is fully declarative and reproducible (in theory).

## Table of Contents

- [Overview](#overview)
- [Systems](#systems)
- [Home Manager Modules](#home-manager-modules)
- [Applying the Configuration](#applying-the-configuration)
  - [NixOS (elendil)](#nixos-elendil)
  - [macOS (mgengarelli)](#macos-mgengarelli)
  - [macOS — Hackintosh (mgengarelli@hackintosh)](#macos--hackintosh-mgengarellihackintosh)
- [Customization](#customization)
- [License](#license)

## Overview

This flake defines system configurations for multiple machines and a macOS home setup, all managed from one place. Overlays, custom packages, and various modules are included for convenience.
The goal is to go from bare metal to a fully configured system with a single command.

## Systems

Two configurations are defined:

- **elendil** — NixOS on a Microsoft Surface Pro (x86_64-linux). KDE Plasma 6, Fish shell, Docker, Steam, PipeWire, and the usual hardware tweaks to make everything work.
  **Custom kernel**: Zen-based kernel with Linux Surface patches, tuned for low latency and Surface hardware support (drivers for touchscreen, cameras, sensors, etc.). Defined in `pkgs/kernel/`.
  **Cloud drives**: OneDrive, ProtonDrive and Google Drive mounted at login via rclone systemd user services (`home/elendil/default.nix`).
- **mgengarelli** — macOS home configuration (aarch64-darwin). Uses home-manager to keep a consistent environment on a Mac.
- **mgengarelli@hackintosh** — macOS home + nix-darwin configuration (x86_64-darwin) on a Surface Laptop 3 running OpenCore. Uses a pinned nixpkgs (`nixos-26.05`) because nixpkgs dropped x86_64-darwin support after that release. Overlays are disabled entirely because they reference packages built against nixpkgs-unstable and are ABI-incompatible with the older pinned set. GUI apps (Ghostty, Proton suite, etc.) are managed declaratively via Homebrew through nix-darwin; CLI tools stay in nixpkgs via Home Manager.

## Home Manager Modules

This flake uses Home Manager to manage per-user configurations across systems.

### Shells & Terminals

- **fish** — Fish shell with plugins and modern Unix utilities
- **ghostty** — Ghostty terminal emulator with custom keybindings

### Editors & IDEs

- **neovim** — NeoVim with mini.nvim framework and LSP support
- **opencode** — OpenCode AI assistant with MCP servers

### Development Tools

- **devops** — Kubernetes, Terraform, Ansible, Azure CLI (kubectl, helm), K9s, Vault, Tanzu
- **git** — Git with Delta for diffs and custom aliases

### Productivity & Communication

- **firefox** — Firefox with privacy policies and pre-configured extensions

### Customization & Appearance

- **fonts** — Font management with monospace fonts, NerdFonts, and custom families

## Applying the Configuration

### NixOS (elendil)

Steps for a fresh NixOS installation:

1. Boot the minimal NixOS ISO from a USB stick.
2. Partition and format the disks as needed, then mount the root filesystem at `/mnt`.
3. Generate a hardware configuration:
   ```bash
   nixos-generate-config --root /mnt
   ```
4. Copy the generated `hardware-configuration.nix` into the appropriate system directory (e.g., `system/elendil/`).
5. Clone this repository to `/mnt/etc/nixos` or your preferred location.
6. Review and adjust the configuration for your hardware and preferences.
   **Note**: before the first switch, configure the rclone remotes with `rclone config` — the mount services use `OneDrivePersonal`, `proton`, and `gdrive`. The `rclone-*` systemd user services will fail to mount until those remotes exist.
7. Build and switch:
   ```bash
   nixos-rebuild switch --flake .#elendil
   ```

### macOS (mgengarelli)

Home-manager only. See the `home/work-darwin/` directory for details.

### macOS — Hackintosh (mgengarelli@hackintosh)

Home-manager + nix-darwin. GUI apps are managed by Homebrew through nix-darwin;
CLI tools and dotfiles are managed by Home Manager. Requires an existing OpenCore
boot setup on x86_64 hardware (Surface Laptop 3).

#### Prerequisites

This configuration assumes **VoltageShift** is already installed and configured.
VoltageShift is a macOS kernel extension (kext) that allows CPU undervolting and
power limit tuning. It is **not** managed by Nix and must be set up manually:

1. **Install the kext and binary** — follow the instructions at
   [VoltageShift](https://github.com/sicreative/VoltageShift). The binary must be
   at `/usr/local/bin/voltageshift`.
2. **Add the kext to OpenCore** — mount the EFI partition, add `VoltageShift.kext`
   to `EFI/OC/Kexts/`, and add a corresponding entry to your `config.plist` under
   `Kernel → Add`. See the VoltageShift README for the exact plist entry.

Once installed, home-manager handles the rest: a `sleepwatcher` agent runs on
login and applies CPU power limits (`voltageshift power 17 25`) every time the
machine wakes from sleep.

#### Applying

```bash
darwin-rebuild switch --flake .#hackintosh    # nix-darwin + Homebrew
home-manager switch --flake .#mgengarelli@hackintosh  # dotfiles
```

**Note:** Before the first `darwin-rebuild switch`, manually uninstall any
Proton apps (VPN, Drive, Pass) already in `/Applications` — Homebrew will
refuse to install a cask over an existing manual installation.

This configuration uses a pinned nixpkgs (`nixos-26.05`) because nixpkgs
dropped x86_64-darwin support after that release. Overlays are disabled, so
some packages (mcp-atlassian) use stubs.

## Customization

This configuration is personal, but feel free to take inspiration. To adapt it for your own use:

1. Copy a system configuration directory (e.g., `system/elendil/`) and rename it
2. Update the hostname in the configuration files
3. Adjust `hardware-configuration.nix` for your hardware
4. Run `nixos-rebuild switch --flake .#your-hostname`

The key directories:

- `system/` — NixOS system configurations per host.
- `home/` — Home Manager modules (neovim, fish, firefox, and more).
- `pkgs/` — Custom package overlays and definitions. Some packages are platform-conditional (e.g. `mcp-atlassian` is excluded on `x86_64-darwin` where its dependency tree is broken).
- `lib/` — Shared utility functions.

## License

See [LICENSE](./LICENSE) for details.
