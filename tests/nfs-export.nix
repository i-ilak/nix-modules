{ lib }:
let
  nfsLib = import ../lib/nfs.nix { inherit lib; };

  serviceToUserMap = {
    serviceA = {
      uid = 1000;
      gid = 100;
    };
  };

  serviceDataA = {
    base = "/srv/data";
    allowedIpRange = [
      { ipv4 = "10.0.0.1"; }
      { ipv4 = "10.0.0.2"; }
    ];
  };

  serviceDataEmpty = {
    base = "/srv/empty";
    allowedIpRange = [ ];
  };
in
{
  testExportFormatting = {
    expr = nfsLib.mkNfsExport "serviceA" serviceDataA serviceToUserMap;
    expected = "/srv/data 10.0.0.1(rw,fsid=1000,wdelay,root_squash,no_all_squash,no_subtree_check)\n/srv/data 10.0.0.2(rw,fsid=1000,wdelay,root_squash,no_all_squash,no_subtree_check)\n";
  };

  testEmptyIpRange = {
    expr = nfsLib.mkNfsExport "serviceA" serviceDataEmpty serviceToUserMap;
    expected = "";
  };
}
