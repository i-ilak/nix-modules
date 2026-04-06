{
  pkgs,
  ...
}:
{
  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };

    masApps = {
      "strongbox" = 897283731;
      "reader" = 1529448980;
      "whatsapp" = 310633997;
      "bitwarden" = 1352778147;
    };
  };

}
