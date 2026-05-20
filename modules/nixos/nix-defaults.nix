{ config, lib, ... }:
let
  cfg = config.infra.nixDefaults;
in
{
  options.infra.nixDefaults = {
    enable = lib.mkEnableOption "shared nix allowed-users / gc / optimise baseline";

    enableGc = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable automatic gc (weekly, --delete-older-than 3d) and optimise (Sun 03:00).";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings.allowed-users = lib.mkDefault [ "root" ];

    nix.gc = lib.mkIf cfg.enableGc {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 3d";
    };

    nix.optimise = lib.mkIf cfg.enableGc {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault [ "Sun 03:00" ];
    };
  };
}
