_:
let
  home = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
in
{
  "${xdg_configHome}/hypr".source = ../../dotfiles/linux/hypr;
  "${xdg_configHome}/waybar".source = ../../dotfiles/linux/waybar;
  "${xdg_configHome}/mako".source = ../../dotfiles/linux/mako;
}
