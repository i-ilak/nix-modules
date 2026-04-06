{ lib }:
{
  mkNfsExport =
    service: serviceData: serviceToUserMap:
    let
      serviceConfig =
        serviceToUserMap.${service}
          or (throw "NFS export: service '${service}' has no entry in infra.users.serviceToUserMap");
      opts = "rw,fsid=${toString serviceConfig.uid},wdelay,root_squash,no_all_squash,no_subtree_check";
      ipAddresses = map (hostConfig: hostConfig.ipv4) serviceData.allowedIpRange;
      fullExports = map (ip: "${serviceData.base} ${ip}(${opts})") ipAddresses;
    in
    if serviceData.allowedIpRange == [ ] then "" else (lib.concatStringsSep "\n" fullExports) + "\n";
}
