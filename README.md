![Lua Linting and Packages](https://github.com/massix/nixos/actions/workflows/ci.yml/badge.svg)
![Last System Update](https://github.com/massix/nixos/actions/workflows/cachix.yml/badge.svg)

# Massi's NixOS Configuration

Personal NixOS configuration and packages for my different systems.

## Systems

### Elendil
* [Main System's configuration here](./system/elendil/configuration.nix);
* [Hardware Configuration's here](./system/elendil/hardware-configuration.nix).

A Surface Laptop 3 computer, using NixOS as my daily driver.  For this system I am using
a [custom kernel](./pkgs/kernel/default.nix) based off of the [zen kernel](https://github.com/zen-kernel/zen-kernel) and the [linux-surface](https://github.com/linux-surface/linux-surface) patches.  This allows
me to have a good configuration for this system, which I mostly use for gaming and
developing.

## Users

### massi@elendil
* [Home Manager's configuration](./home/elendil/default.nix);

Main (and only) user of Elendil.

## Packages
All the packages are defined [here](./pkgs/default.nix).

### Onedriver
Custom compilation of the [onedriver](https://github.com/jstaf/onedriver) software, for which I am also the official maintainer
for [nixpkgs](https://github.com/nixos/nixpkgs).  The only difference between this package and the one in nixpkgs is that here
I am using the latest version from the master branch.

### Lombok
Simple derivation to download a specific version of the Lombok jar, mostly to be used with
the JDTLS package.

### Codeium Language Server
Download and patching of the [Codeium's language server](https://github.com/Exafunction/codeium), which I use extensively in Neovim.
The version here is **not always the latest** available, but the one needed for their vim plugin.

### VSCode JS Debug
Download, compilation and patching of VSCode's JS Debug extension, to be used with the DAP
adapter for Neovim.

### Spotube
Audio player for my music collection.

### Tana
Note-taking tool, this is a mirror of the package which is available on `nixpkgs`, for which I
am also the maintainer.

### Warp Terminal
Terminal with AI, I use this instead of the one available in `nixpkgs` because I do not want
to always use the latest version, due to some incompatibilities with GTK from time to time.

