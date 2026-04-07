{
  config,
  lib,
  ...
}:
let
  cfg = config.infra.persist;

  # Absolute filesystem path: must begin with `/` and have at least one more
  # character. Rejects empty strings, relative paths, and bare `/`.
  absolutePathType = lib.types.strMatching "^/.+$";

  # POSIX user/group name (IEEE Std 1003.1-2017, §3.437): characters from the
  # portable filename character set [A-Za-z0-9._-], and shall not begin with a
  # hyphen. We also forbid a leading `.` since `.` and `..` are reserved path
  # components and no real service account uses them. Covers every account we
  # use (redis-authentik, tandoor_recipes, influxdb2, 123user, ...) while
  # rejecting "user!", "user name", "-user", or an empty string.
  userOrGroupType = lib.types.strMatching "^[A-Za-z0-9_][A-Za-z0-9._-]*$";

  # 3 or 4 octal digits. Matches "0755", "755", "0700", "0710", ... while
  # rejecting "bogus", "700z", "8000", or the symbolic `chmod` form
  # (`u=rwx,g=rx`). If a symbolic mode is ever needed, relax this regex.
  octalModeType = lib.types.strMatching "^[0-7]{3,4}$";

  entryType = lib.types.submodule {
    options = {
      directory = lib.mkOption {
        type = lib.types.nullOr absolutePathType;
        default = null;
        description = "Absolute path of a directory to persist. Mutually exclusive with `file`.";
      };
      file = lib.mkOption {
        type = lib.types.nullOr absolutePathType;
        default = null;
        description = ''
          Absolute path of a single file to persist. Mutually exclusive with
          `directory`. File entries cannot carry `user`/`group`/`mode` —
          impermanence's `files` submodule only supports directories for
          ownership/mode, so setting any of those fields on a file entry is
          rejected by an assertion.
        '';
      };
      user = lib.mkOption {
        type = lib.types.nullOr userOrGroupType;
        default = null;
        description = ''
          Owner applied the first time the directory is created under the
          persist root. Only valid on `directory` entries — impermanence does
          not chown files.

          Leave `null` when the owning service manages ownership at runtime
          (e.g. systemd `StateDirectory=` with `User=` or `DynamicUser=true`,
          or any service whose unit chowns its state dir on start). In that
          case impermanence applies its own default (root:root) on fresh
          `/persist` and the service corrects ownership on first start.

          Note: impermanence only chowns when the persisted directory does
          not yet exist under the persist root, so this field is effectively
          a fresh-install default — it does not re-chown an existing tree.
        '';
      };
      group = lib.mkOption {
        type = lib.types.nullOr userOrGroupType;
        default = null;
        description = ''
          Group applied the first time the directory is created under the
          persist root. Same rules as `user`: directory-only, null means the
          service (or impermanence's root default) handles it.
        '';
      };
      mode = lib.mkOption {
        type = lib.types.nullOr octalModeType;
        default = null;
        description = ''
          Octal mode (3 or 4 digits, e.g. `0700`, `0755`) applied the first
          time the directory is created under the persist root. Directory-only.
          Null defers to impermanence's default (0755). Symbolic `chmod` forms
          are intentionally rejected — use numeric octal.
        '';
      };
      reason = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Free-form note explaining why this path needs to survive reboots. Doc/grep aid only — not used at build time.";
      };
    };
  };

  # Convert a directory entry to impermanence's `directories` format. Only
  # emit user/group/mode when the caller explicitly set them, so impermanence
  # can apply its own defaults (root:root:0755) for unset fields. This lets
  # the config distinguish "I'm asserting this ownership" from "the service
  # owns it at runtime" without lying about root ownership in the latter.
  toDir =
    e:
    {
      inherit (e) directory;
    }
    // lib.optionalAttrs (e.user != null) { inherit (e) user; }
    // lib.optionalAttrs (e.group != null) { inherit (e) group; }
    // lib.optionalAttrs (e.mode != null) { inherit (e) mode; };

  # impermanence's `files` submodule does not accept user/group/mode (only
  # `directories` does), so we forward the bare path. The assertion below
  # enforces that callers don't try to set ownership on file entries rather
  # than silently dropping those fields.
  toFile = e: e.file;

  dirEntries = builtins.filter (e: e.directory != null) cfg.entries;
  fileEntries = builtins.filter (e: e.file != null) cfg.entries;
in
{
  options.infra.persist = {
    enable = lib.mkEnableOption "per-service persistence aggregation via impermanence";

    root = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
      description = "Mount point that holds preserved state across reboots.";
    };

    entries = lib.mkOption {
      type = lib.types.listOf entryType;
      default = [ ];
      description = ''
        Persistence declarations contributed by service modules. Each entry
        names exactly one path (directory or file) that must survive a reboot
        of an impermanent host. The aggregator turns these into a single
        `environment.persistence.<root>` block.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      (map (e: {
        assertion = (e.directory == null) != (e.file == null);
        message = "infra.persist.entries: each entry must set exactly one of `directory` or `file` (got directory=${toString e.directory} file=${toString e.file}).";
      }) cfg.entries)
      ++ (map (e: {
        assertion = e.file == null || (e.user == null && e.group == null && e.mode == null);
        message = "infra.persist.entries: file entry `${toString e.file}` cannot set `user`/`group`/`mode` — impermanence only applies ownership and permissions to directory entries. Drop those fields or convert the entry to a directory.";
      }) cfg.entries);

    environment.persistence.${cfg.root} = {
      hideMounts = true;
      directories = map toDir dirEntries;
      files = map toFile fileEntries;
    };
  };
}
