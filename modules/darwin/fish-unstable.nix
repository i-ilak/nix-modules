# Function-module pattern: this module takes `nixpkgs-unstable` as an argument
# because flake inputs are not available in the standard module system `config`.
# Consumers apply it as:
#   (inputs.nix-modules.darwinModules.fish-unstable { nixpkgs-unstable = inputs.nixpkgs-unstable; })
{ nixpkgs-unstable }:
{ lib, config, ... }:
let
  cfg = config.infra.fishUnstable;
in
{
  options.infra.fishUnstable = {
    enable = lib.mkEnableOption "fish from nixpkgs-unstable (aarch64-darwin code-signature workaround for nixos-25.11)";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: _: {
        inherit
          (
            (import nixpkgs-unstable {
              inherit (final.stdenv.hostPlatform) system;
              config.allowUnfree = true;
            })
          )
          fish
          ;
      })
    ];
  };
}
