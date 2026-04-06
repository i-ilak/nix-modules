{
  pkgs,
  lib,
  ...
}:
{
  programs.helix = {
    extraPackages = with pkgs; [ nil ];
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
          language-servers = [ "nil" ];
        }
      ];

      language-server.nil = {
        command = "${pkgs.nil}/bin/nil";
        config.nil = {
          nix.flake.autoArchive = true;
          formatting.command = [ "${lib.getExe pkgs.nixfmt}" ];
        };
      };
    };
  };
}
