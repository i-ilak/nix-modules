{
  config,
  ...
}:
let
  inherit (config.infra.desktop) fontSize;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "buttonless";
        dynamic_title = true;
        opacity = 0.98;
        #option_as_alt   = "Both";
        title = "Alacritty";
        padding = {
          x = 5;
          y = 5;
        };
        startup_mode = "Maximized";
      };
      mouse.hide_when_typing = true;
      font = {
        size = fontSize;
        normal = {
          family = "MesloLGS NF";
          style = "Regular";
        };
        bold = {
          family = "MesloLGS NF";
          style = "Bold";
        };
        italic = {
          family = "MesloLGS NF";
          style = "Italic";
        };
        bold_italic = {
          family = "MesloLGS NF";
          style = "Bold Italic";
        };
      };
      keyboard.bindings = [ ];
    };
  };
}
