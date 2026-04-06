{
  pkgs,
  lib,
  config,
  ...
}:
let
  polybarCfg = config.infra.desktop.polybar;

  glyph = {
    fill = "";
    empty = "";
    indicator = "⏽";
    gleft = "";
    gright = "";
  };

  color = {
    background = "#1F1F1F";
    foreground = "#FFFFFF";
    foreground-alt = "#FFFFFF";

    network = "#1F7D53";
    cpu = "#255F38";
    memory = "#27391C";
    filesystem = "#18230F";
  };
in
lib.mkIf (polybarCfg != null) {
  services.polybar =
    let
      inherit (polybarCfg) monitor;
      inherit (polybarCfg.network) interface;
    in
    {
      enable = true;
      package = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };
      config = {
        "settings" = {
          screenchange-reload = "true";
        };

        "bar/top-main" = {
          monitor = "${monitor}";
          width = "100%";
          height = "20";
          fixed-center = "true";
          line-size = "1";
          padding-left = "1";
          padding-right = "1";
          module-margin-left = "0";
          module-margin-right = "0";
          font-0 = "MesloLGS NF:antialias=true;2";
          modules-left = "i3";
          modules-center = "date";
          modules-right = "right_network network right_cpu cpu right_memory memory right_fs filesystem";
          wm-restack = "i3";
          cursor-click = "pointer";
          cursor-scroll = "ns-resize";
        };

        "module/i3" = {
          type = "internal/i3";
          index-sort = "true";
          wrapping-scroll = "false";
          # ws-icon-0 = "1;%{F#F65F12} %{F-}";
          # ws-icon-1 = "2;%{F#3C8642} %{F-}";
          # ws-icon-2 = "3; ";
          # ws-icon-3 = "4;%{F#1E88E5} %{F-}";
          # ws-icon-4 = "5; ";
          # ws-icon-5 = "6; ";
          # ws-icon-6 = "7; ";
          # ws-icon-7 = "8;%{F#D91D57} %{F-}";
          # ws-icon-8 = "9;%{F#205FB6} %{F-}";
          # ws-icon-9 = "10;%{F#1DD05D}♫ %{F-}";
          ws-icon-default = "";
          format = "<label-state>";
          # label-focused = "%icon%";
          label-focused-padding = "2";
          label-focused-underline = "#FFF";
          # label-unfocused = "%icon%";
          label-unfocused-padding = "2";
          # label-visible = "%icon%";
          label-visible-padding = "2";
          # label-urgent = "%icon%";
          label-urgent-background = "#C37561";
          label-urgent-padding = "2";
        };

        "module/right_network" = {
          type = "custom/text";
          content-background = "${color.background}";
          content-foreground = "${color.network}";
          content = "${glyph.gright}";
          content-font = 2;
        };

        "module/network" = {
          type = "internal/network";
          interface = "${interface}";
          interval = "1.0";
          accumulate-stats = true;
          unknown-as-up = true;

          format-connected = "<ramp-signal> <label-connected>";
          format-connected-background = "${color.network}";
          format-connected-padding = 1;

          format-disconnected = "<label-disconnected>";
          format-disconnected-prefix = "ﲁ";
          format-disconnected-background = "${color.network}";
          format-disconnected-padding = 1;

          label-connected = " %{T3}%upspeed:9% %{T-}${glyph.indicator}  %{T3}%downspeed:9% %{T-}";
          label-disconnected = "%{A1:networkmanager_dmenu &:} Offline %{A}";

          ramp-signal-0 = "說";
          ramp-signal-1 = "說";
          ramp-signal-2 = "說";
        };

        "module/right_cpu" = {
          type = "custom/text";
          content-background = "${color.network}";
          content-foreground = "${color.cpu}";
          content = "${glyph.gright}";
          content-font = 2;
        };

        "module/cpu" = {
          type = "internal/cpu";
          interval = "1";
          format = "<label>";
          format-prefix = "﬙ ";
          format-background = "${color.cpu}";
          format-padding = 2;
          label = "%percentage:2%%";

          bar-load-width = 10;
          bar-load-gradient = false;

          bar-load-indicator = "${glyph.indicator}";
          bar-load-indicator-foreground = "${color.foreground}";

          bar-load-fill = "${glyph.fill}";
          bar-load-foreground-0 = "${color.foreground}";
          bar-load-foreground-1 = "${color.foreground}";
          bar-load-foreground-2 = "${color.foreground}";

        };

        "module/right_memory" = {
          type = "custom/text";
          content-background = "${color.cpu}";
          content-foreground = "${color.memory}";
          content = "${glyph.gright}";
          content-font = 2;
        };

        "module/memory" = {
          type = "internal/memory";
          interval = 2;
          format = "<label>";
          format-prefix = " ";
          format-background = "${color.memory}";
          format-padding = 2;
          label = "%percentage_used:2%%";
          bar-used-width = 10;
          bar-used-gradient = false;
          bar-used-indicator = "${glyph.indicator}";
          bar-used-indicator-foreground = "${color.foreground}";
          bar-used-fill = "${glyph.fill}";
          bar-used-foreground-0 = "${color.foreground}";
          bar-used-foreground-1 = "${color.foreground}";
          bar-used-foreground-2 = "${color.foreground}";
          bar-used-empty = "${glyph.empty}";
          bar-used-empty-foreground = "${color.foreground}";
        };

        "module/right_fs" = {
          type = "custom/text";
          content-background = "${color.memory}";
          content-foreground = "${color.filesystem}";
          content = "${glyph.gright}";
          content-font = 2;
        };

        "module/filesystem" = {
          type = "internal/fs";

          mount-0 = "/";
          interval = 30;
          fixed-values = false;

          format-mounted = "<label-mounted>";
          format-mounted-prefix = " ";
          format-mounted-background = "${color.filesystem}";
          format-mounted-padding = 2;

          format-unmounted = "<label-unmounted>";
          format-unmounted-prefix = " ";
          format-unmounted-background = "${color.filesystem}";
          format-unmounted-padding = 2;

          label-mounted = "%used%/%total%";

          label-unmounted = "%mountpoint%: not mounted";

          bar-used-width = 10;
          bar-used-gradient = false;

          bar-used-indicator = "${glyph.indicator}";
          bar-used-indicator-foreground = "${color.background}";

          bar-used-fill = "${glyph.fill}";
          bar-used-foreground-0 = "${color.background}";
          bar-used-foreground-1 = "${color.background}";
          bar-used-foreground-2 = "${color.background}";

          bar-used-empty = "${glyph.empty}";
          bar-used-empty-foreground = "${color.background}";
        };

        "module/date" = {
          type = "internal/date";
          interval = "1";
          date = "%A %d %B";
          time = "at %H:%M";
          label = "%date% %time%";
          format-prefix = " ";
          format-prefix-foreground = "#AB71FD";
        };

        "module/tray" = {
          type = "internal/tray";
          tray-spacing = "0px";
        };

        "global/wm" = {
          margin-top = "5";
          margin-bottom = "5";
        };
      };
      script = ''
        export DISPLAY=$DISPLAY
        export XAUTHORITY=$HOME/.Xauthority
        killall -q polybar
        while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
        PATH=$PATH:${pkgs.i3}/bin polybar top-main &
      '';
    };

  systemd.user.services.polybar.Unit = {
    After = [ "graphical-session.target" ];
    Requires = [ "graphical-session.target" ];
  };
}
