# nix-modules

Reusable, secret-free Nix modules for home-manager, NixOS, and nix-darwin.

## Usage

Add as a flake input:

```nix
{
  inputs.nix-modules = {
    url = "github:i-ilak/nix-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then import modules in your configuration:

```nix
# Home-manager modules
inputs.nix-modules.homeManagerModules.git
inputs.nix-modules.homeManagerModules.fish
inputs.nix-modules.homeManagerModules.infra-options

# NixOS modules
inputs.nix-modules.nixosModules.hardening
inputs.nix-modules.nixosModules.locale

# nix-darwin modules
inputs.nix-modules.darwinModules.system
inputs.nix-modules.darwinModules.aerospace
```

## Module Outputs

### homeManagerModules

`infra-options`, `git`, `fish`, `helix`, `alacritty`, `ghostty`, `i3`, `i3-status-rust`, `polybar`, `direnv`, `fzf`, `lazygit`, `rofi`, `dunst`, `zsh`, `beets`, `mako`, `shared-packages`, `default`

### nixosModules

`infra-options`, `hardening`, `locale`, `nfs-client`, `nfs-server`, `restic-backup`, `packages`

### darwinModules

`infra-options`, `system`, `dock`, `desktoppr`, `homebrew`, `aerospace`, `casks`

### lib

`nfs` — NFS export helper functions

## Configuration Options

Modules use the `infra.*` option namespace. Import `infra-options` and set values in your config:

```nix
{
  infra.host = {
    user = "myuser";
    hostname = "myhost";
    homeDir = "/home/myuser";
  };
  infra.git = {
    userName = "My Name";
    userEmail = "me@example.com";
  };
  infra.desktop = {
    fontSize = 13;
    i3.modifier = "Mod4";
  };
}
```

## Design Principles

- **No secrets or personal values** — modules declare options, consumers set values
- **No hostname branching** — behavior is controlled via option values
- **Parameterized paths** — uses `config.infra.host.homeDir` instead of hardcoded paths
