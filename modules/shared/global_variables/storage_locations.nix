{
  lib,
  ...
}:
{
  options.infra.storage = lib.mkOption {
    type = lib.types.submodule {
      options.services = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              base = lib.mkOption { type = lib.types.str; };
              dataDir = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              backupDir = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              mediaDir = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              musicDir = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              stateDir = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              nfsExport = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether this service's base path should be NFS-exported.";
              };
              allowedIpRange = lib.mkOption {
                type = lib.types.listOf lib.types.attrs;
                default = [ ];
                description = "List of IP entries (from infra.network.ipMap) allowed to access this share.";
              };
            };
          }
        );
      };
    };
    default = { };
    description = "Storage path definitions for services.";
  };

}
