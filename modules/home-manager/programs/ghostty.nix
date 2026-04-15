{ lib, ... }:
{
  config.programs.ghostty = {
    enable = true;
    package = lib.mkDefault null;
    enableFishIntegration = true;
    settings = {
      theme = lib.mkDefault "catppuccin-mocha";
      gtk-titlebar = lib.mkDefault false;
      font-size = lib.mkDefault 14;
      font-family = lib.mkDefault "UDEV Gothic NF Regular";
      font-family-bold = lib.mkDefault "UDEV Gothic NF Bold";
      font-family-italic = lib.mkDefault "UDEV Gothic NF Italic";
      font-family-bold-italic = lib.mkDefault "UDEV Gothic NF Bold Italic";
      font-feature = lib.mkDefault "-calt";

      clipboard-read = lib.mkDefault "allow";
      clipboard-write = lib.mkDefault "allow";
      window-theme = lib.mkDefault "dark";
      macos-titlebar-style = lib.mkDefault "tabs";
      maximize = lib.mkDefault true;
    };
  };
}
