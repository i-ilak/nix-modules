{ config, lib, ... }:
let
  cfg = config.infra.nixHomebrew;
in
{
  options.infra.nixHomebrew = {
    enable = lib.mkEnableOption "the shared nix-homebrew baseline (user from infra.host.user, mutableTaps=false, autoMigrate=true)";
    taps = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      description = "Map of `owner/repo` tap names to source paths (typically flake inputs).";
      example = lib.literalExpression ''
        {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    nix-homebrew = {
      enable = true;
      inherit (config.infra.host) user;
      inherit (cfg) taps;
      mutableTaps = false;
      autoMigrate = true;
    };
  };
}
