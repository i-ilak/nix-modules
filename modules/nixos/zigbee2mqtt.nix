{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.infra.zigbee2mqtt;

  # Write secrets.yaml from the password file before Z2M starts so that
  # `!secret mqtt_password` in configuration.yaml resolves at runtime.
  # Runs as root ('+' prefix) so it can read sops-managed secret files.
  preStartScript = pkgs.writeShellScript "zigbee2mqtt-secrets" ''
    install -m 600 -o zigbee2mqtt -g zigbee2mqtt /dev/null "${cfg.dataDir}/secrets.yaml"
    printf 'mqtt_password: %s\n' "$(< ${cfg.mqtt.passwordFile})" \
      > "${cfg.dataDir}/secrets.yaml"
  '';
in
{
  options.infra.zigbee2mqtt = {
    enable = lib.mkEnableOption "Zigbee2MQTT bridge (Zigbee → MQTT)";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/zigbee2mqtt";
      description = ''
        State directory. Contains configuration.yaml, the auto-generated Zigbee
        network key, and secrets.yaml. BACK THIS UP — losing it means re-pairing
        every device on the network.
      '';
    };

    serialPort = lib.mkOption {
      type = lib.types.str;
      description = ''
        Serial device path for the Zigbee adapter. Must be a stable
        /dev/serial/by-id/… path. Never use /dev/ttyUSB* — it renumbers on
        hotplug and silently breaks the bridge.
      '';
    };

    adapter = lib.mkOption {
      type = lib.types.str;
      default = "ember";
      description = ''
        Adapter type passed to Zigbee2MQTT. Use "ember" for Silicon Labs EFR32
        chipsets (Sonoff ZBDongle-E MG24, Sonoff ZBDongle-P v2, etc.).
        Use "zstack" for Texas Instruments CC2652/CC1352 chipsets.
      '';
    };

    mqtt = {
      server = lib.mkOption {
        type = lib.types.str;
        default = "mqtt://127.0.0.1:1883";
        description = "MQTT broker URL (e.g. mqtt://127.0.0.1:1883).";
      };

      user = lib.mkOption {
        type = lib.types.str;
        description = "MQTT username Zigbee2MQTT authenticates with.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.path;
        description = ''
          Path to a file containing the plaintext MQTT password for this user.
          Provide a sops secret path so the password never enters the Nix store.
          Written to secrets.yaml in dataDir at service start.
        '';
      };
    };

    frontend = {
      enable = lib.mkEnableOption "Zigbee2MQTT web frontend";

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address to bind the frontend to. Default is loopback-only; expose via a reverse proxy if external access is needed.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "TCP port for the web frontend.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/dev/serial/by-id/" cfg.serialPort;
        message = ''
          infra.zigbee2mqtt.serialPort must use a stable /dev/serial/by-id/… path.
          Got: "${cfg.serialPort}"
          Run `ls -l /dev/serial/by-id/` on the host to find the correct path.
        '';
      }
    ];

    services.zigbee2mqtt = {
      enable = true;
      dataDir = cfg.dataDir;
      settings =
        {
          serial = {
            port = cfg.serialPort;
            adapter = cfg.adapter;
          };
          mqtt = {
            base_topic = "zigbee2mqtt";
            server = cfg.mqtt.server;
            user = cfg.mqtt.user;
            # Resolved at runtime from secrets.yaml written by preStartScript.
            password = "!secret mqtt_password";
          };
          homeassistant = true;
          permit_join = false;
          advanced.log_level = "info";
        }
        // lib.optionalAttrs cfg.frontend.enable {
          frontend = {
            host = cfg.frontend.host;
            port = cfg.frontend.port;
          };
        };
    };

    systemd.services.zigbee2mqtt.serviceConfig = {
      # Write secrets.yaml before Z2M starts; runs as root to read sops secrets.
      ExecStartPre = [ "+${preStartScript}" ];
      # Grant access to the serial tty without running the service as root.
      SupplementaryGroups = [ "dialout" ];
    };
  };
}
