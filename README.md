# NixOS Configuration

A personal NixOS configuration repository managed with **Flakes** and **Home Manager**. Yes, another dotfiles repo — but at least this one is fully declarative and reproducible (in theory).

## Table of Contents

- [Overview](#overview)
- [Systems](#systems)
- [Home Manager Modules](#home-manager-modules)
- [Applying the Configuration](#applying-the-configuration)
  - [NixOS (elendil / aiwendil)](#nixos-elendil--aiwendil)
  - [macOS (mgengarelli)](#macos-mgengarelli)
- [Customization](#customization)
- [License](#license)

## Overview

This flake defines system configurations for multiple machines and a macOS home setup, all managed from one place. Overlays, custom packages, and various modules are included for convenience.
The goal is to go from bare metal to a fully configured system with a single command.

## Systems

Three configurations are defined:

- **elendil** — NixOS on a Microsoft Surface Pro (x86_64-linux). KDE Plasma 6, Fish shell, Docker, Steam, PipeWire, and the usual hardware tweaks to make everything work.
  **Custom kernel**: Zen-based kernel with Linux Surface patches, tuned for low latency and Surface hardware support (drivers for touchscreen, cameras, sensors, etc.). Defined in `pkgs/kernel/`.
- **aiwendil** — NixOS on WSL2 (x86_64-linux). Minimal setup with Docker and SSH for development in a Windows-hosted Linux environment.
- **mgengarelli** — macOS home configuration (aarch64-darwin). Uses home-manager to keep a consistent environment on a Mac.

## Home Manager Modules

This flake uses Home Manager to manage per-user configurations across systems.

### Shells & Terminals

- **fish** — Fish shell with plugins and modern Unix utilities
- **ghostty** — Ghostty terminal emulator with custom keybindings
- **kitty** — Kitty terminal with ligatures support
- **zellij** — Zellij terminal multiplexer with custom layouts

### Editors & IDEs

- **neovim** — NeoVim with mini.nvim framework and LSP support
- **opencode** — OpenCode AI assistant with MCP servers

### Development Tools

- **devops** — Kubernetes, Terraform, Ansible, Azure CLI (kubectl, helm), K9s, Vault, Tanzu
- **git** — Git with Delta for diffs and custom aliases

### Task Management

- **taskwarrior** — Task manager with custom reports and Jira UDA integration

### Productivity & Communication

- **firefox** — Firefox with privacy policies and pre-configured extensions
- **Messaging** — Instant messaging clients (Telegram, WhatsApp)
- **gleeter** — XKCD comic viewer for the terminal

### Customization & Appearance

- **fonts** — Font management with monospace fonts, NerdFonts, and custom families
- **gaming** — Game configs for Dwarf Fortress, NetHack, Cataclysm DDA

## Applying the Configuration

### NixOS (elendil / aiwendil)

Steps for a fresh NixOS installation:

1. Boot the minimal NixOS ISO from a USB stick.
2. Partition and format the disks as needed, then mount the root filesystem at `/mnt`.
3. Generate a hardware configuration:
   ```bash
   nixos-generate-config --root /mnt
   ```
4. Copy the generated `hardware-configuration.nix` into the appropriate system directory (e.g., `system/elendil/` or `system/aiwendil/`).
5. Clone this repository to `/mnt/etc/nixos` or your preferred location.
6. Review and adjust the configuration for your hardware and preferences.
7. Build and switch:
   ```bash
   nixos-rebuild switch --flake .#elendil
   ```
   Replace `elendil` with `aiwendil` for the WSL configuration.

For WSL specifically, install NixOS-WSL first (see [github.com/nix-community/nixos-wsl](https://github.com/nix-community/nixos-wsl)) and then apply the `aiwendil` configuration following a similar process.

### macOS (mgengarelli)

The macOS configuration uses nix-darwin and home-manager. See the `home/work-darwin/` directory for details.

## Customization

This configuration is personal, but feel free to take inspiration. To adapt it for your own use:

1. Copy a system configuration directory (e.g., `system/elendil/`) and rename it
2. Update the hostname in the configuration files
3. Adjust `hardware-configuration.nix` for your hardware
4. Run `nixos-rebuild switch --flake .#your-hostname`

The key directories:

- `system/` — NixOS system configurations per host.
- `home/` — Home Manager modules (neovim, fish, kitty, firefox, taskwarrior, and more).
- `pkgs/` — Custom package overlays and definitions.
- `lib/` — Shared utility functions.

## License

See [LICENSE](./LICENSE) for details.
