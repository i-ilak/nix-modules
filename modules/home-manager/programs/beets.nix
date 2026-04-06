{ config, ... }:
let
  inherit (config.infra.host) homeDir;
in
{
  programs.beets = {
    enable = true;
    settings = {
      directory = "${homeDir}/share/external/navidrome/music/";
      library = "${homeDir}/share/external/navidrome/music/musiclibrary.db";
      import.move = true;
      permissions = {
        file = 640;
        dir = 750;
      };
      plugins = "musicbrainz fetchart embedart permissions";
    };
  };
}
