![Nix and Lua Linting](https://github.com/massix/nixos/actions/workflows/lint-lua-nix.yml/badge.svg)

# Massi's NixOS Configuration

Welcome to my personal NixOS configuration.  This repository has been made mostly
for testing out what NixOS can do and see how I can leverage on the paradigm of
immutable systems in order to build the _perfect_ configuration (at least for my own needs).

At the moment of writing this file, it does contain the configuration for two
different systems:
 * **elendil**: my personal laptop (Microsoft Surface Laptop 3 running NixOS)
 * **coravandil**: the WSL on Windows 11 that I use at work, which uses Ubuntu
 23.04 as the base system.

I plan to add a third one (a Lenovo Yoga currently running Fedora) in the near
future.

The whole configuration uses the _not-so-experimental_ feature of
[Nix Flakes](https://nixos.wiki/wiki/Flakes) along with a bunch of dependencies
and tries to be _as generic as possible_ in regarding of the system itself.

## Elendil's Configuration
You will find the configuration for **elendil** in the [system/elendil](./system/elendil)
folder, it is composed of the classic `configuration.nix` file, containing the
system itself and `hardware-configuration.nix`, which contains the custom
linux kernel configuration.

## Coravandil's Configuration
Since this is not a physical machine, there's nothing under the system folder
for Coravandil, everything is in the configuration of the user, made using
the excellent home-manager module.

## Users
Two users are currently configured: `massi@elendil` and `massi@coravandil`. Since
the two users share most of the things, I created reusable home-manager modules
to easily configure them.


## Home Manager Modules
I have created multiple modules for the users.

### Base
As the name suggets, this is the base module, containing the initial things
that have to be configured. Here I am using `homeage` in order to safely encrypt
and decrypt the secrets for my users (for example the SSH key).

### Fish
This is the module for the `fish` shell, which also installs a bunch of tools,
configures some of the aliases and abbrs that I use on all the systems.

### Fonts
This is the first module I wrote: it just installs a bunch of fonts and configures
the fontconfig.

### Helix
This is the module for the `helix` editor.

### IM
A module that simply installs `whatsapp`, `telegram` and `discord`

### NeoVim
This is the most complex and unstable module I wrote, the idea was to port my
whole nvim configuration (which was quite old since I switched to VSCode) to
the Nix ecosystem, make it immutable and such. It is kinda working right now,
there are still a couple of bugs that I have to fix but it can be used for Java
development without any issues.
