{ lib, config, ... }:
{
  options.infra = {
    host = lib.mkOption {
      type = lib.types.submodule {
        options = {
          hostname = lib.mkOption {
            type = lib.types.str;
            description = "Logical hostname used in infra options (distinct from networking.hostName).";
          };
          user = lib.mkOption {
            type = lib.types.str;
            default = "root";
            description = "Primary user account on this host.";
          };
          homeDir = lib.mkOption {
            type = lib.types.str;
            default = "/root";
            description = "Home directory of the primary user.";
          };
          interface = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Primary network interface name (e.g. enp89s0).";
          };
          sshAuthSock = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Path to SSH agent socket (e.g. Bitwarden SSH agent).";
          };
        };
      };
      default = { };
      description = "Per-host identity and basic settings.";
    };

    services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.port = lib.mkOption {
            type = lib.types.port;
            description = "TCP port the service listens on.";
          };
        }
      );
      default = { };
      description = "Per-service port configuration.";
    };

    git = lib.mkOption {
      type = lib.types.submodule {
        options = {
          userName = lib.mkOption {
            type = lib.types.str;
            description = "Git user.name for commits.";
          };
          userEmail = lib.mkOption {
            type = lib.types.str;
            description = "Git user.email for commits.";
          };
          signingKeyPath = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Path to SSH key used for git commit signing.";
          };
          allowedSignersFile = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Path to the allowed_signers file for git signature verification.";
          };
          useAdWrapper = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Wrap git with LD_PRELOAD for Active Directory NSS resolution.";
          };
        };
      };
      default = { };
      description = "Git identity and signing configuration.";
    };

    sshPublicKeys = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Named SSH public keys used across the infrastructure (e.g. admin, deploy).";
    };

    desktop = lib.mkOption {
      type = lib.types.submodule {
        options = {
          fontSize = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "Terminal font size (used by alacritty).";
          };
          i3 = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.submodule {
                options.modifier = lib.mkOption {
                  type = lib.types.str;
                  description = "i3 modifier key (e.g. Mod1, Mod4).";
                };
              }
            );
            default = null;
            description = "i3 window manager settings.";
          };
          polybar = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.submodule {
                options = {
                  monitor = lib.mkOption {
                    type = lib.types.str;
                    description = "X11 monitor name for polybar (e.g. HDMI-1).";
                  };
                  network = lib.mkOption {
                    type = lib.types.submodule {
                      options.interface = lib.mkOption {
                        type = lib.types.str;
                        description = "Network interface shown in polybar's network module.";
                      };
                    };
                    description = "Network settings for polybar.";
                  };
                };
              }
            );
            default = null;
            description = "Polybar status bar settings.";
          };
        };
      };
      default = { };
      description = "Desktop environment settings (i3, polybar, terminal).";
    };
  };

  config.assertions =
    let
      ports = lib.mapAttrsToList (name: v: {
        inherit name;
        inherit (v) port;
      }) config.infra.services;
      portValues = map (p: p.port) ports;
      hasDuplicates = list: lib.length list != lib.length (lib.unique list);
      findDuplicatePorts =
        let
          grouped = builtins.groupBy (p: toString p.port) ports;
        in
        lib.concatStringsSep ", " (
          lib.concatLists (
            lib.mapAttrsToList (
              port: entries:
              if lib.length entries > 1 then
                [ "port ${port} used by: ${lib.concatMapStringsSep ", " (e: e.name) entries}" ]
              else
                [ ]
            ) grouped
          )
        );
    in
    [
      {
        assertion = !hasDuplicates portValues;
        message = "infra.services: duplicate ports detected — ${findDuplicatePorts}";
      }
    ];

  imports = [
    ./networking.nix
    ./storage_locations.nix
    ./users.nix
  ];
}
