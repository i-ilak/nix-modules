{
  config,
  lib,
  ...
}:
let
  cfg = config.infra.nfs.server;
  nfsLib = import ../../lib/nfs.nix { inherit lib; };
  inherit (config.infra.users) serviceToUserMap;
  inherit (config.infra.storage) services;

  exportableServices = lib.filterAttrs (
    _: svcData: svcData.nfsExport && svcData.allowedIpRange != [ ]
  ) services;

  mkExport = service: serviceData: nfsLib.mkNfsExport service serviceData serviceToUserMap;
  serviceExports = lib.concatStringsSep "\n" (lib.mapAttrsToList mkExport exportableServices);
  extraExports = lib.concatStringsSep "\n" cfg.extraExports;
  exports = ''
    ${serviceExports}
    ${extraExports}
  '';
in
{
  options.infra.nfs.server = {
    enable = lib.mkEnableOption "NFS server with auto-generated exports from infra.storage.services";

    extraExports = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional raw NFS export lines appended after auto-generated exports.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nfs = {
      server = {
        inherit exports;
        enable = true;
      };
      settings = {
        nfsd = {
          vers3 = false;
          vers4 = true;
          "vers4.2" = true;
        };
      };
    };
  };
}
