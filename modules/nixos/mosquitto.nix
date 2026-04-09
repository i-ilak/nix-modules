{
  config,
  lib,
  ...
}:
let
  cfg = config.infra.mosquitto;
in
{
  options.infra.mosquitto = {
    enable = lib.mkEnableOption "local Mosquitto MQTT broker (loopback-only by default)";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address to listen on. Default is loopback-only; change only if external access is needed.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1883;
      description = "TCP port to listen on.";
    };

    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.hashedPasswordFile = lib.mkOption {
            type = lib.types.path;
            description = ''
              Path to a file containing the pre-hashed mosquitto password entry for
              this user (one line, output of `mosquitto_passwd`). Provide a sops
              secret path so the plaintext never enters the Nix store.
            '';
          };
        }
      );
      default = { };
      description = "MQTT users keyed by username. Each user gets read/write access to all topics (`#`).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          address = cfg.listenAddress;
          port = cfg.port;
          settings.allow_anonymous = false;
          users = lib.mapAttrs (_: userCfg: {
            hashedPasswordFile = userCfg.hashedPasswordFile;
            acl = [ "readwrite #" ];
          }) cfg.users;
        }
      ];
    };
  };
}
