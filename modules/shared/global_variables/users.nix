{
  lib,
  ...
}:
{
  options.infra.users = lib.mkOption {
    type = lib.types.submodule {
      options = {
        serviceToUserMap = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                uid = lib.mkOption { type = lib.types.int; };
                gid = lib.mkOption { type = lib.types.int; };
              };
            }
          );
          description = "Mapping of service names to UID/GID pairs.";
        };
        backupGroup = lib.mkOption {
          type = lib.types.int;
          description = "GID for the backup group.";
        };
        mediaGroup = lib.mkOption {
          type = lib.types.int;
          description = "GID for the media group.";
        };
      };
    };
    default = { };
    description = "Service user UID/GID mappings and shared group IDs.";
  };
}
