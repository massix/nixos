# NixOS Configuration

This repository contains my NixOS configuration, managed using flakes and Home Manager.

## Highlights

*   **Systems Built:** This configuration builds NixOS for 2 Linux systems (Elendil and Aiwëndil) and one Darwin system (my work's laptop).
*   **Custom Packages:** The `pkgs` directory defines several custom packages:
    *   `codeium-ls`: the language server from Codeium (now Windsurf), used in NeoVim;
    *   `tanzu`: the Tanzu CLI I use at work;
    *   `tridentctl`: the Trident CLI I use at work;
    *   `onedriver` (Linux only)
    *   `custom-kernel` (Linux only)
*   **User Configurations:** Home Manager is used to manage user environments for `massi@elendil`, `massi@aiwendil`, and `mgengarelli`, ensuring consistency across different systems.
*   **Existing Modules:** The `home/modules` directory contains a variety of Home Manager modules for configuring different aspects of the user environment:
    *   `gleeter`: contains default configuration for [Gleeter](https://github.com/massix/gleeter), a tool I use to browse [XKCD](https://xkcd.com) comics from the terminal;
    *   `fish`: contains defaults for the `fish` shell;
    *   `fonts`: installation of default fonts across all systems;
    *   `devops`: installation of tools dedicated to my main job (I am a Platform Engineer);
    *   `git`
    *   `zellij`
    *   `firefox`
    *   `kitty`
    *   `im`
    *   `neovim` (with extensive sub-modules)
    *   `ghostty`
    *   `taskwarrior`
    *   `gaming`

## System Details

### Elendil

*   Runs the GNOME Desktop Environment.
*   Uses `fish` shell.
*   Includes Docker and VirtualBox for virtualization.

### Aiwendil

*   Runs in WSL (Windows Subsystem for Linux).

### mgengarelli

*   Runs on Darwin (macOS).

