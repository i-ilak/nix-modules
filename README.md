# nix-modules

Reusable, secret-free Nix modules for home-manager, NixOS, and nix-darwin.

## Usage

Add as a flake input:

```nix
{
  inputs.nix-modules = {
    url = "git+https://tangled.org/ilak.ch/nix-modules?ref=main";
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

`infra-options`, `hardening`, `infra-monitoring`, `infra-networking`, `locale`, `mosquitto`, `nfs-client`, `nfs-server`, `packages`, `persist`, `restic-backup`, `zigbee2mqtt`, `default`

### darwinModules

`infra-options`, `system`, `dock`, `desktoppr`, `homebrew`, `aerospace`, `casks`, `power`

### lib

`nfs` — NFS export helper functions
`vim` — vim/ideavim/vscode configuration generators

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

### Profiles (NixOS)

The `infra-networking`, `infra-monitoring`, and `hardening` modules expose `infra.profiles.*` options for high-level, opinionated configuration shared across a personal fleet:

```nix
{
  # SSH hardening — see modules/nixos/hardening/sshd.nix
  infra.profiles.sshd = {
    allowUsers = [ "root" ];
    ports = [ 22023 ];
  };

  # Static networking + firewall — see modules/nixos/infra-networking.nix
  infra.profiles.networking = {
    enable = true;
    interface = "enp3s0";
    extraTcpPorts = [ 80 443 ];
    monitoringExporters = [ "node_exporter" "systemd_exporter" ];
  };

  # Prometheus exporters + promtail — see modules/nixos/infra-monitoring.nix
  infra.profiles.monitoring = {
    enable = true;
    listenAddress = "10.0.0.1";
    exporters = [ "node" "systemd" ];
    promtail = {
      enable = true;
      hostLabel = "myhost";
    };
  };
}
```

## Design Principles

- **No secrets or personal values** — modules declare options, consumers set values
- **No hostname branching** — behavior is controlled via option values
- **Parameterized paths** — uses `config.infra.host.homeDir` instead of hardcoded paths
