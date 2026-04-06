{
  config,
  lib,
  ...
}:
let
  cfg = config.services.resticBackup;
in
{
  options.services.resticBackup = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Paths to back up.";
          };
          sopsFile = lib.mkOption {
            type = lib.types.path;
            default = config.sops.defaultSopsFile;
            description = "Sops file containing B2 credentials for this service.";
          };
          initialize = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to initialize the restic repository.";
          };
          useBackupGroup = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to run the restic service with Group=backup. Needed for NFS paths with root_squash.";
          };
          passwordSecret = lib.mkOption {
            type = lib.types.str;
            default = "restic-password-file";
            description = "Name of the sops secret containing the restic repository password.";
          };
        };
      }
    );
    default = { };
    description = "Declarative restic backup configurations with automatic sops secret wiring.";
  };

  config = {
    sops.secrets = lib.mkMerge (
      lib.optional (cfg != { }) {
        "restic-password-file" = {
          owner = "root";
          group = "backup";
          mode = "0440";
        };
      }
      ++ lib.mapAttrsToList (name: serviceCfg: {
        "${name}-b2-endpoint" = {
          key = "${name}/b2/endpoint";
          owner = "root";
          group = "backup";
          mode = "0440";
          inherit (serviceCfg) sopsFile;
        };
        "${name}-b2-bucket_name" = {
          key = "${name}/b2/bucket_name";
          owner = "root";
          group = "backup";
          mode = "0440";
          inherit (serviceCfg) sopsFile;
        };
        "${name}-b2-account_id" = {
          key = "${name}/b2/account_id";
          owner = "root";
          group = "backup";
          mode = "0440";
          inherit (serviceCfg) sopsFile;
        };
        "${name}-b2-application_key" = {
          key = "${name}/b2/application_key";
          owner = "root";
          group = "backup";
          mode = "0440";
          inherit (serviceCfg) sopsFile;
        };
      }) cfg
    );

    sops.templates = lib.mkMerge (
      lib.mapAttrsToList (name: _: {
        "${name}-repositoryFile" = {
          content = "s3:${config.sops.placeholder."${name}-b2-endpoint"}/${
            config.sops.placeholder."${name}-b2-bucket_name"
          }";
          owner = "root";
          group = "backup";
          mode = "0440";
        };
        "${name}-accessFile" = {
          content = ''
            AWS_ACCESS_KEY_ID="${config.sops.placeholder."${name}-b2-account_id"}"
            AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."${name}-b2-application_key"}"
          '';
          owner = "root";
          group = "backup";
          mode = "0440";
        };
      }) cfg
    );

    services.restic.backups = lib.mapAttrs (name: serviceCfg: {
      inherit (serviceCfg) initialize;
      user = "root";
      inherit (serviceCfg) paths;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 10"
      ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      environmentFile = config.sops.templates."${name}-accessFile".path;
      repositoryFile = config.sops.templates."${name}-repositoryFile".path;
      passwordFile = config.sops.secrets.${serviceCfg.passwordSecret}.path;
    }) cfg;

    systemd.services = lib.mapAttrs' (
      name: serviceCfg:
      lib.nameValuePair "restic-backups-${name}" (
        lib.mkIf serviceCfg.useBackupGroup {
          serviceConfig.Group = "backup";
        }
      )
    ) cfg;
  };
}
