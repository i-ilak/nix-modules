_: {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      gtk-titlebar = false;
      font-size = 14;
      font-family = "UDEV Gothic NF Regular";
      font-family-bold = "UDEV Gothic NF Bold";
      font-family-italic = "UDEV Gothic NF Italic";
      font-family-bold-italic = "UDEV Gothic NF Bold Italic";
      font-feature = "-calt";

      clipboard-read = "allow";
      clipboard-write = "allow";
      window-theme = "dark";
      macos-titlebar-style = "hidden";
    };
  };
}
