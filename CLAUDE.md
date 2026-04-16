# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Public, reusable Nix modules for home-manager, NixOS, and nix-darwin. These modules are secret-free and generic — they declare options and provide configurable defaults. Personal values and secrets are set by consuming flakes (nix-config, work-nix-config).

## Commands

```bash
# Format all Nix files (treefmt: nixfmt)
nix fmt

# Lint Nix code
nix run nixpkgs#statix -- check .

# Find dead/unused Nix code
nix run nixpkgs#deadnix -- .

# Run tests
nix flake check
```

## Nix Option Search

Always use `manix` to search NixOS, Home Manager, and nix-darwin options:

```bash
manix "services.openssh"
manix "programs.zsh"
```

Use `--source` to restrict results when the option type is known:

```bash
manix --source nixos_options "services.openssh"
manix --source hm_options "programs.zsh"
manix --source nd_options "system.defaults"
```

Available sources: `hm_options`, `nd_options`, `nixos_options`, `nixpkgs_doc`, `nixpkgs_tree`, `nixpkgs_comments`

`manix` is installed on `plessur` in `nix-config` (`hosts/plessur/packages.nix`).

## Architecture

### Module Categories

- **`modules/shared/global_variables/`** — Option declarations for `infra.host`, `infra.network`, `infra.services`, `infra.git`, `infra.desktop`, `infra.emails`, `infra.tailscale`, `infra.storage`, `infra.users`. No config values — consumers set these.
- **`modules/shared/`** — Cross-platform utilities: formatting (treefmt), scripts, system packages.
- **`modules/home-manager/programs/`** — User environment modules: fish, git, helix, alacritty, ghostty, fzf, direnv, lazygit, rofi, dunst, polybar, i3-status-rust, zsh, beets, mako.
- **`modules/home-manager/`** — i3 window manager config, shared packages.
- **`modules/nixos/`** — NixOS modules: locale, security hardening (audit, kernel, sshd, sudo, usbguard, noexec), NFS client/server, restic backup, packages.
- **`modules/darwin/`** — macOS modules: system settings, aerospace, dock, desktoppr (wallpaper), homebrew, casks.
- **`dotfiles/`** — Shared dotfiles (vimrc, ideavimrc, vscode settings, ccache config).
- **`lib/`** — Utility functions (NFS export helpers).
- **`tests/`** — Unit tests for lib functions.

### Flake Outputs

```
homeManagerModules.{infra-options, git, fish, helix, alacritty, ghostty, i3, ...}
nixosModules.{infra-options, hardening, locale, nfs-client, nfs-server, restic-backup, packages}
darwinModules.{infra-options, system, dock, desktoppr, homebrew, aerospace, casks}
lib.nfs
```

### Key Design Principles

- **No secrets, no personal values** — modules only declare options and use `config.infra.*` to read values set by the consumer.
- **No hostname checks** — modules use option values (e.g., `config.infra.host.sshAuthSock`) instead of `if hostname == "foo"` branching.
- **Parameterized paths** — use `config.infra.host.homeDir` instead of hardcoded `/home/iilak`.
- **Consumer passes `flakeRoot`** — function-style imports like `shared_packages.nix` accept `flakeRoot` to resolve paths within this repo (scripts, dotfiles).

## Consumed By

| Repo | How |
|------|-----|
| nix-config (private) | `inputs.nix-modules` — personal hosts (plessur, maloja, bernina, moesa, albula) |
| work-nix-config (private) | `inputs.nix-modules` — work hosts (mxw-dalco01) |
