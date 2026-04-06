{ config, ... }:
{
  services.aerospace = {
    enable = true;
    settings = {
      # Normalizations
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      # Accordion padding
      accordion-padding = 16;

      # Default root container layout and orientation
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      # Key mapping preset
      key-mapping = {
        preset = "qwerty";
      };

      # On-focus change behaviors
      on-focus-changed = [ "move-mouse window-lazy-center" ];
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      # Gaps
      gaps = {
        inner = {
          horizontal = 2;
          vertical = 2;
        };
        outer = {
          left = 2;
          bottom = 2;
          top = 2;
          right = 2;
        };
      };

      # Workspace to monitor force assignment
      # workspace-to-monitor-force-assignment = {
      #   1 = 1;
      #   2 = 1;
      #   3 = 1;
      #   4 = 2;
      #   5 = 2;
      #   6 = 2;
      #   7 = 3;
      #   8 = 3;
      #   9 = 3;
      #   };

      # On window detected rules
      # on-window-detected = [
      #   {
      #     if = {
      #     app-id = "com.timpler.screenstudio";
      #   };
      #   check-further-callbacks = false;
      #   run = "layout floating";
      #   }
      # ];

      # Mode main binding
      mode = {
        main = {
          binding = {
            # Layout commands
            alt-slash = "layout accordion horizontal vertical";
            alt-backslash = "layout tiles horizontal vertical";
            alt-enter = "exec-and-forget ${config.infra.host.homeDir}/.nix-profile/bin/alacritty";

            # Fullscreen commands
            alt-shift-q = "close";
            alt-e = "macos-native-minimize";
            alt-m = "fullscreen";

            # Workspace navigation
            alt-left = "workspace --wrap-around prev";
            alt-right = "workspace --wrap-around next";
            alt-shift-c = "reload-config";
            alt-shift-f = "layout floating tiling";
            f11 = "fullscreen";

            # Mode commands
            alt-shift-m = "mode manage";
            alt-shift-r = "mode resize";

            # Focus commands
            alt-h = "focus left";
            alt-j = "focus down";
            alt-k = "focus up";
            alt-l = "focus right";

            # Move commands
            alt-shift-h = "move left";
            alt-shift-j = "move down";
            alt-shift-k = "move up";
            alt-shift-l = "move right";

            # Resize commands
            alt-shift-minus = "resize smart -50";
            alt-shift-equal = "resize smart +50";

            # Workspace commands
            alt-1 = "workspace 1";
            alt-2 = "workspace 2";
            alt-3 = "workspace 3";
            alt-4 = "workspace 4";
            alt-5 = "workspace 5";
            alt-6 = "workspace 6";
            alt-7 = "workspace 7";
            alt-8 = "workspace 8";
            alt-9 = "workspace 9";
            alt-0 = "workspace 10";

            # Move node to workspace
            alt-shift-1 = "move-node-to-workspace 1";
            alt-shift-2 = "move-node-to-workspace 2";
            alt-shift-3 = "move-node-to-workspace 3";
            alt-shift-4 = "move-node-to-workspace 4";
            alt-shift-5 = "move-node-to-workspace 5";
            alt-shift-6 = "move-node-to-workspace 6";
            alt-shift-7 = "move-node-to-workspace 7";
            alt-shift-8 = "move-node-to-workspace 8";
            alt-shift-9 = "move-node-to-workspace 9";
            alt-shift-0 = "move-node-to-workspace 10";

            # Move node and switch to workspace
            alt-ctrl-1 = [
              "move-node-to-workspace 1"
              "workspace 1"
            ];
            alt-ctrl-2 = [
              "move-node-to-workspace 2"
              "workspace 2"
            ];
            alt-ctrl-3 = [
              "move-node-to-workspace 3"
              "workspace 3"
            ];
            alt-ctrl-4 = [
              "move-node-to-workspace 4"
              "workspace 4"
            ];
            alt-ctrl-5 = [
              "move-node-to-workspace 5"
              "workspace 5"
            ];
            alt-ctrl-6 = [
              "move-node-to-workspace 6"
              "workspace 6"
            ];
            alt-ctrl-7 = [
              "move-node-to-workspace 7"
              "workspace 7"
            ];
            alt-ctrl-8 = [
              "move-node-to-workspace 8"
              "workspace 8"
            ];
            alt-ctrl-9 = [
              "move-node-to-workspace 9"
              "workspace 9"
            ];
            alt-ctrl-0 = [
              "move-node-to-workspace 10"
              "workspace 10"
            ];

            # Back and forth workspace navigation
            alt-tab = "workspace-back-and-forth";

            # Move workspace to monitor
            alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
          };
        };

        service = {
          binding = {
            esc = [
              "reload-config"
              "mode main"
            ];
            r = [
              "flatten-workspace-tree"
              "mode main"
            ];
            f = [
              "layout floating tiling"
              "mode main"
            ];
            backspace = [
              "close-all-windows-but-current"
              "mode main"
            ];
            alt-h = [
              "join-with left"
              "mode main"
            ];
            alt-j = [
              "join-with down"
              "mode main"
            ];
            alt-k = [
              "join-with up"
              "mode main"
            ];
            alt-l = [
              "join-with right"
              "mode main"
            ];
          };
        };
      };

    };
  };
}
