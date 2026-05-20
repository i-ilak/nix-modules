{ config, lib, ... }:
let
  cfg = config.infra.gitSopsSigning;
in
{
  options.infra.gitSopsSigning = {
    enable = lib.mkEnableOption "git commit/tag signing wired through sops-nix";
    sopsFile = lib.mkOption {
      type = lib.types.path;
      description = "Default sops file containing the signing key secret.";
    };
    secretName = lib.mkOption {
      type = lib.types.str;
      example = "ssh_git_signing_key/public";
      description = "Name of the sops secret holding the SSH signing key.";
    };
    ageKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      defaultText = lib.literalExpression ''"''${config.infra.host.homeDir}/Library/Application Support/sops/age/keys.txt"'';
      description = "Path to the age key file used by sops. Defaults to the darwin sops-age path under infra.host.homeDir.";
    };
  };

  config = lib.mkIf cfg.enable {
    infra.git = {
      signingKeyPath = config.sops.secrets.${cfg.secretName}.path;
      allowedSignersFile = config.sops.templates."allowed_signers".path;
    };

    sops = {
      defaultSopsFile = cfg.sopsFile;
      age.keyFile = lib.mkDefault (
        if cfg.ageKeyFile != null then
          cfg.ageKeyFile
        else
          "${config.infra.host.homeDir}/Library/Application Support/sops/age/keys.txt"
      );
      secrets.${cfg.secretName} = { };
      templates."allowed_signers".content = ''
        * ${config.sops.placeholder.${cfg.secretName}}
      '';
    };
  };
}
