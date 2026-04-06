{
  alacritty = {
    enable = true;
    settings = {
      layer = "top";
      position = "top";
      spacing = 5;
      height = 26;
      modules-left = [
        "hyprland/workspaces"
        "idle_inhibitor"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "custom/packages"
        "network"
        "pulseaudio"
        "backlight"
        "battery"
        "custom/date"
      ];

      "hyprland/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{icon}";
        persistent-workspaces = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
          "5" = [ ];
        };
        format-icons = {
          "1" = "󰋜";
          "2" = "󰈹";
          "3" = "󰊢";
          "4" = "󰭹";
          "5" = "󱓷";
        };
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰂄 {capacity}%";
        format-alt = "{time} {icon}";
        format-full = "󱈑 {capacity}%";
        format-icons = [
          "󱊡"
          "󱊢"
          "󱊣"
        ];
      };

      "custom/date" = {
        format = "󰸗 {}";
        interval = 3600;
        exec = "~/.config/waybar/waybar_date.sh";
      };

      "custom/bat" = {
        exec = "~/.config/waybar/bat.sh";
        interval = 5;
      };

      "custom/microphone" = {
        exec = "~/.config/waybar/microphone.sh";
        on-click = "pavucontrol";
        format = "{}";
        interval = 2;
      };

      bluetooth = {
        format = "󰂲";
        format-connected = "";
        tooltip-format = "{controller_alias}\t{controller_address}\n {num_connections} connected";
        tooltip-format-connected = "{controller_alias}\t{controller_address}\n {num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        on-click = "kitty -e bluetoothctl";
      };

      network = {
        format-wifi = "{icon}";
        format-icons = [
          "󰤯"
          "󰤟"
          "󰤢"
          "󰤢"
          "󰤨"
        ];
        format-ethernet = "{ipaddr}/{cidr}";
        format-disconnected = "󰤮";
        tooltip-format-wifi = "{essid}, Strength: {signalStrength}%";
        tooltip-format-ethernet = "";
        max-length = 50;
        on-click = "alacritty";
      };

      backlight = {
        device = "intel_backlight";
        format = "{percent}% {icon}";
        format-icons = [
          "󰃚"
          "󰃛"
          "󰃜"
          "󰃝"
          "󰃞"
          "󰃟"
          "󰃠"
        ];
        tooltip = false;
      };

      pulseaudio = {
        scroll-step = 5;
        format = "{volume}% {icon}";
        format-icons = [
          ""
          ""
          ""
        ];
        format-muted = "  󰝟";
        on-click = "wpctl set-mute @DEFAULT_SINK@ toggle";
        on-click-right = "pavucontrol";
      };

      clock = {
        interval = 60;
        tooltip-format = "{calendar}";
        calendar = {
          format = {
            today = "<b><u>{}</u></b>";
          };
        };
        timezone = "Europe/Zurich";
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "󰒲";
        };
      };

      "custom/packages" = {
        interval = 3600;
        exec-if = "ping -nc 1 wttr.in";
        exec = "~/.config/waybar/packages.sh";
        signal = 8;
        tooltip = false;
      };

      "custom/power" = {
        format = "󰐥";
        on-click = "~/.config/waybar/waybar_power.sh";
      };

      cpu = {
        interval = 1;
        format = " {}%";
        max-length = 10;
        on-click = "";
      };
    };
  };
}
