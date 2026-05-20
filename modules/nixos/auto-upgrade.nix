{ config, lib, inputs, ... }:
let
  cfg = config.infra.autoUpgrade;
in
{
  options.infra.autoUpgrade = {
    enable = lib.mkEnableOption "scheduled system upgrades that refresh selected flake inputs";

    inputsToUpdate = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "nixpkgs"
        "nix-modules"
      ];
      description = ''
        Flake input names to refresh on each upgrade run. Translated into
        `--update-input <name>` flags appended after extraFlags. NOTE:
        `--update-input` is deprecated upstream (nixpkgs#349734) but has no
        drop-in replacement for store-path flakes.
      '';
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "-L" ];
      description = "Flags prepended before the --update-input entries.";
    };

    dates = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "systemd OnCalendar expression for the upgrade timer.";
    };

    randomizedDelaySec = lib.mkOption {
      type = lib.types.str;
      default = "45min";
      description = "systemd RandomizedDelaySec for the upgrade timer.";
    };
  };

  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = cfg.extraFlags ++ map (n: "--update-input ${n}") cfg.inputsToUpdate;
      inherit (cfg) dates randomizedDelaySec;
    };
  };
}
