_: {
  programs.helix = {
    settings = {
      editor = {
        line-number = "relative";
        bufferline = "multiple";
        default-yank-register = "+";
        shell = [
          "bash"
          "-c"
        ];
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        indent-guides = {
          character = "╎";
          render = true;
        };
        color-modes = true;
        popup-border = "all";
        # rainbow-brackets = true; # Not yet in 25.05
        trim-trailing-whitespace = true;
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "spacer"
            "separator"
            "file-name"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "workspace-diagnostics"
            "position"
            "total-line-numbers"
            "position-percentage"
            "file-encoding"
            "file-line-ending"
            "file-type"
            "register"
            "selections"
          ];
          separator = "│";
          mode = {
            normal = "N";
            insert = "I";
            select = "V";
          };
        };
        file-picker = {
          hidden = false;
        };
      };
      keys = {
        normal = {
          "s" = ":w";
          "0" = "goto_line_start";
          "$" = "goto_line_end";
          "^" = "goto_first_nonwhitespace";
          "tab" = "goto_next_buffer";
          "S-tab" = "goto_previous_buffer";
          "A-x" = "extend_to_line_bounds";
          "X" = "select_line_above";
          "V" = [
            "select_mode"
            "extend_to_line_bounds"
          ];
          "esc" = [
            "collapse_selection"
            "keep_primary_selection"
          ];
          "f" = {
            "f" = "file_picker";
            "u" = "goto_reference";
            "g" = "global_search";
            "s" = "symbol_picker";
          };
          "r" = {
            "r" = "rename_symbol";
          };
        };
        select = {
          "A-x" = "extend_to_line_bounds";
          "X" = "select_line_above";
          "0" = "goto_line_start";
          "$" = "goto_line_end";
          "^" = "goto_first_nonwhitespace";
          "D" = [
            "extend_to_line_bounds"
            "delete_selection"
            "normal_mode"
          ];
          "k" = [
            "extend_line_up"
            "extend_to_line_bounds"
          ];
          "j" = [
            "extend_line_down"
            "extend_to_line_bounds"
          ];
        };
      };
    };
    ignores = [
      "flake.lock"
    ];
  };
}
