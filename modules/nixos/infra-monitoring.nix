{ config, lib, ... }:
let
  cfg = config.infra.profiles.monitoring;
in
{
  options.infra.profiles.monitoring = {
    enable = lib.mkEnableOption "fleet monitoring (prometheus exporters + optional promtail)";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      description = "Listen address for prometheus exporters.";
    };

    exporters = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "node"
          "systemd"
          "unbound"
        ]
      );
      default = [
        "node"
        "systemd"
      ];
      description = "Which prometheus exporters to enable on this host.";
    };

    promtail = {
      enable = lib.mkEnableOption "ship journald to remote loki via promtail";
      lokiHost = lib.mkOption {
        type = lib.types.str;
        default = "maloja";
        description = "Hostname key in infra.network.ipMap pointing at loki.";
      };
      hostLabel = lib.mkOption {
        type = lib.types.str;
        description = "Label for this host in promtail scrape config.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters = lib.mkMerge [
      (lib.mkIf (builtins.elem "node" cfg.exporters) {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          inherit (config.infra.services.node_exporter) port;
          inherit (cfg) listenAddress;
        };
      })
      (lib.mkIf (builtins.elem "systemd" cfg.exporters) {
        systemd = {
          enable = true;
          inherit (config.infra.services.systemd_exporter) port;
          inherit (cfg) listenAddress;
        };
      })
      (lib.mkIf (builtins.elem "unbound" cfg.exporters) {
        unbound = {
          enable = true;
          inherit (config.infra.services.unbound_exporter) port;
          inherit (cfg) listenAddress;
          unbound = {
            host = "unix:///${config.services.unbound.settings.remote-control.control-interface}";
            ca = null;
            certificate = null;
            key = null;
          };
          group = "unbound";
        };
      })
    ];

    services.promtail = lib.mkIf cfg.promtail.enable {
      enable = true;
      configuration = {
        server = {
          http_listen_port = config.infra.services.promtail.port;
          grpc_listen_port = 0;
        };

        clients = [
          {
            url = "http://${config.infra.network.ipMap.${cfg.promtail.lokiHost}.ipv4}:${toString config.infra.services.loki.port}/loki/api/v1/push";
          }
        ];

        positions.filename = "/run/promtail/positions.yaml";

        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = cfg.promtail.hostLabel;
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };

    systemd.services.promtail = lib.mkIf cfg.promtail.enable {
      serviceConfig.RuntimeDirectory = "promtail";
    };
  };
}
