{
  lib,
  ...
}:
let
  ipAddressType = lib.types.submodule {
    options = {
      ipv4 = lib.mkOption { type = lib.types.str; };
      ipv6 = lib.mkOption { type = lib.types.str; };
    };
  };

  hostIpType = lib.types.submodule {
    options = {
      ipv4 = lib.mkOption { type = lib.types.str; };
      ipv6 = lib.mkOption { type = lib.types.str; };
      vlan = lib.mkOption { type = lib.types.str; };
    };
  };
in
{
  options.infra = {
    network = lib.mkOption {
      type = lib.types.submodule {
        options = {
          publicDomain = lib.mkOption {
            type = lib.types.str;
            description = "Public DNS domain used for service subdomains and ACME certs.";
          };
          ipMap = lib.mkOption {
            type = lib.types.attrsOf hostIpType;
            description = "Per-host IP addresses and VLAN assignments.";
          };
          vlan = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule {
                options.gateway = lib.mkOption {
                  type = ipAddressType;
                  description = "Gateway IP addresses for this VLAN.";
                };
              }
            );
            description = "VLAN definitions with gateway addresses.";
          };
          gatewayMap = lib.mkOption {
            type = lib.types.attrsOf ipAddressType;
            description = "Pre-computed gateway addresses per host.";
          };
          ipv4IpRange = lib.mkOption {
            type = lib.types.str;
            description = "IPv4 CIDR range covering all VLANs.";
          };
          ipv6IpRange = lib.mkOption {
            type = lib.types.str;
            description = "IPv6 CIDR range covering all VLANs.";
          };
          nfs = lib.mkOption {
            type = lib.types.submodule {
              options.port = lib.mkOption {
                type = lib.types.port;
                description = "Base NFS TCP port.";
              };
            };
          };
        };
      };
      default = { };
      description = "Network topology: IPs, VLANs, gateways, and domain.";
    };

    emails = lib.mkOption {
      type = lib.types.submodule {
        options = {
          personal = lib.mkOption {
            type = lib.types.str;
            description = "Personal email address.";
          };
          work = lib.mkOption {
            type = lib.types.str;
            description = "Work email address.";
          };
          auth = lib.mkOption {
            type = lib.types.str;
            description = "Email address used for authentication services (e.g. Authentik).";
          };
        };
      };
      default = { };
      description = "Email addresses used across the infrastructure.";
    };

    tailscale = lib.mkOption {
      type = lib.types.submodule {
        options.exposedHosts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "Hostnames whose subnets are advertised via Tailscale.";
        };
      };
      default = { };
      description = "Tailscale configuration for advertised routes.";
    };
  };

}
