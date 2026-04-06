{
  inputs,
  flakeRoot ? inputs.self,
  ...
}:
let
  home = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
in
{
  "${xdg_configHome}/hypr".source = flakeRoot + /dotfiles/linux/hypr;
  "${xdg_configHome}/waybar".source = flakeRoot + /dotfiles/linux/waybar;
  "${xdg_configHome}/mako".source = flakeRoot + /dotfiles/linux/mako;
}
