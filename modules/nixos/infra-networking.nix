{ config, lib, ... }:
let
  cfg = config.infra.profiles.networking;
  exporterPorts = lib.mapAttrs (_: e: e.port or null) (
    lib.filterAttrs (n: _: builtins.elem n cfg.monitoringExporters) {
      inherit (config.infra.services)
        node_exporter
        systemd_exporter
        unbound_exporter
        prometheus
        loki
        ;
    }
  );
  monitoringTcpPorts = builtins.filter (p: p != null) (builtins.attrValues exporterPorts);
in
{
  options.infra.profiles.networking = {
    enable = lib.mkEnableOption "infra-fleet static networking profile";

    interface = lib.mkOption {
      type = lib.types.str;
      description = "Primary interface name (e.g. enp3s0, enp89s0, end0).";
    };

    extraTcpPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
      description = "Extra TCP ports to open in the firewall.";
    };

    extraUdpPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ ];
      description = "Extra UDP ports to open in the firewall.";
    };

    nameservers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "DNS resolvers for /etc/resolv.conf.";
    };

    includeNfsPorts = lib.mkEnableOption "open NFS port from infra.network.nfs.port";

    monitoringExporters = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "node_exporter"
          "systemd_exporter"
          "unbound_exporter"
          "prometheus"
          "loki"
        ]
      );
      default = [ ];
      description = "infra.services exporter names whose ports to open in the TCP firewall.";
    };

    extraFirewallCommands = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra raw iptables commands appended to firewall.extraCommands.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      hostName = config.infra.host.hostname;
      useDHCP = false;
      inherit (cfg) nameservers;
      defaultGateway.address = config.infra.network.gatewayMap.${config.infra.host.hostname}.ipv4;
      interfaces.${cfg.interface}.ipv4.addresses = [
        {
          address = config.infra.network.ipMap.${config.infra.host.hostname}.ipv4;
          prefixLength = 24;
        }
      ];
      firewall = {
        enable = true;
        allowedTCPPorts =
          cfg.extraTcpPorts
          ++ lib.optionals cfg.includeNfsPorts [ config.infra.network.nfs.port ]
          ++ monitoringTcpPorts;
        allowedUDPPorts = cfg.extraUdpPorts;
        extraCommands = cfg.extraFirewallCommands;
      };
    };
  };
}
