{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.local.desktoppr;
  inherit (pkgs) stdenv;
in
{
  options = {
    local.desktoppr = {
      enable = mkOption {
        description = "Enable setting of wallpaper with `desktoppr`";
        default = stdenv.isDarwin;
        example = false;
      };

      wallpapers = mkOption {
        description = "Wallpapers to be set for different screens!";
        type =
          with types;
          listOf (submodule {
            options = {
              desktop = lib.mkOption { type = int; };
              name = lib.mkOption { type = str; };
            };
          });
        readOnly = true;
      };

      username = mkOption {
        description = "Username to apply the dock settings to";
        type = types.str;
      };

      repo = mkOption {
        description = "GitHub repository for wallpapers ({owner}/{repo})";
        type = types.submodule {
          options = {
            owner = mkOption {
              type = types.str;
              description = "GitHub owner of the wallpapers repo.";
            };
            name = mkOption {
              type = types.str;
              default = "wallpapers";
              description = "GitHub repo name for wallpapers.";
            };
            rev = mkOption {
              type = types.str;
              default = "main";
              description = "Git revision to fetch.";
            };
            sha256 = mkOption {
              type = types.str;
              description = "Hash of the fetched repo.";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (
    let
      repo = pkgs.fetchFromGitHub {
        inherit (cfg.repo) owner rev sha256;
        repo = cfg.repo.name;
      };
      wallpaper_map = builtins.fromJSON (builtins.readFile "${repo}/wallpapers.json");
      setWallpapers = concatMapStrings (
        entry:
        let
          wallpaperUrl = wallpaper_map.wallpapers.${entry.name};
        in
        "/usr/local/bin/desktoppr ${toString entry.desktop} '${wallpaperUrl}'\n"
      ) cfg.wallpapers;
    in
    {
      system.activationScripts.postActivation.text = ''
        echo >&2 "Setting up wallpapers..."

        su ${cfg.username} -s /bin/sh <<'USERBLOCK'
        ${setWallpapers} 
        USERBLOCK
      '';
    }
  );
}
