{
  config,
  lib,
  ...
}:
let
  cfg = config.infra.nfs.client;

  defaultOptions = [
    "nfsvers=4.2"
    "_netdev"
    "x-systemd.requires=network-online.target"
    "x-systemd.automount"
  ];
in
{
  options.infra.nfs.client = {
    enable = lib.mkEnableOption "NFS client with declarative mounts from infra.network.ipMap";

    server = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of the NFS server (looked up in infra.network.ipMap).";
    };

    mounts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            remotePath = lib.mkOption {
              type = lib.types.str;
              description = "Remote NFS path on the server.";
            };
            extraOptions = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Additional mount options appended to the defaults.";
            };
          };
        }
      );
      default = { };
      description = "NFS mounts keyed by local mount path.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.supportedFilesystems = [ "nfs4" ];
    fileSystems =
      let
        serverIp = config.infra.network.ipMap.${cfg.server}.ipv4;
        mkMount = _: mountCfg: {
          device = "${serverIp}:${mountCfg.remotePath}";
          fsType = "nfs4";
          options = defaultOptions ++ mountCfg.extraOptions;
        };
      in
      lib.mapAttrs mkMount cfg.mounts;
  };
}
