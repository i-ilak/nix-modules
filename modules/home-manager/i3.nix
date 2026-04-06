{
  pkgs,
  lib,
  config,
  ...
}:
let
  i3Cfg = config.infra.desktop.i3;
in
lib.mkIf (i3Cfg != null) {
  xsession.windowManager.i3 =
    let
      inherit (i3Cfg) modifier;
    in
    {
      enable = true;
      config = {
        modifier = "${modifier}";
        fonts = {
          names = [
            "MesloLGS NF Normal"
            "FontAwesome 9"
          ];
          # style = "Bold Semi-Condensed";
          size = 11.0;
        };
        focus = {
          followMouse = false;
        };
        colors = {
          focused = {
            background = "#e2e2e3";
            border = "#e2e2e3";
            childBorder = "#e2e2e3";
            indicator = "#e2e2e3";
            text = "#e2e2e3";
          };
        };
        floating = {
          modifier = "${modifier}";
        };
        gaps = {
          inner = 5;
          outer = 2;
        };
        window = {
          commands = [
            {
              command = "floating enable";
              criteria = {
                class = "^scope.*";
              };
            }
          ];
          border = 4;
          titlebar = false;
        };
        bars = [ ];
        startup = [
          {
            command = "dex --autostart --environment i3";
            always = true;
            notification = false;
          }
          {
            command = "exec i3-msg workspace 1";
            always = true;
            notification = false;
          }
          {
            command = "nm-applet";
            always = true;
            notification = false;
          }
          {
            command = "nitrogen --restore";
            always = true;
            notification = false;
          }
        ];
        keybindings = {
          "${modifier}+Return" = "exec ${config.infra.host.homeDir}/.nix-profile/bin/alacritty"; # Cannot use it because of nixGL wrapper
          "${modifier}+Shift+q" = "kill";
          "${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";

          "XF86AudioRaiseVolume" =
            "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status";
          "XF86AudioLowerVolume" =
            "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status";
          "XF86AudioMute" =
            "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status";
          "XF86AudioMicMute" =
            "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status";

          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          "${modifier}+h" = "split h";
          "${modifier}+v" = "split v";

          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+a" = "focus parent";

          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";

          "${modifier}+Shift+1" = "move container to workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10";

          "${modifier}+Ctrl+Up" = "resize grow height 1 px or 1 ppt";
          "${modifier}+Ctrl+Down" = "resize shrink height 1 px or 1 ppt";
          "${modifier}+Ctrl+Right" = "resize grow width 1 px or 1 ppt";
          "${modifier}+Ctrl+Left" = "resize shrink width 1 px or 1 ppt";

          "${modifier}+m" = "exec ${pkgs.flameshot}/bin/flameshot gui";

          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+r" = "restart";

          "${modifier}+Shift+e" =
            "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'\"";
        };
      };
    };
}
