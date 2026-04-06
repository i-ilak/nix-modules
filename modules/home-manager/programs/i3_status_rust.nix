_: {
  programs.i3status-rust = {
    enable = true;
    bars = {
      top = {
        blocks = [
          {
            block = "time";
            interval = 60;
            format = "$icon $timestamp.datetime(f:'%Y-%m-%d %R')";
            timezone = "Europe/Zurich";
          }
          { block = "cpu"; }
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
            interval = 20;
            warning = 20.0;
            alert = 10.0;
            format = " $icon root: $available.eng(w:2) ";
          }
          {
            block = "memory";
            format = " $icon $mem_total_used_percents.eng(w:2) ";
            format_alt = " $icon_swap $swap_used_percents.eng(w:2) ";
          }
        ];
        icons = "awesome4";
        theme = "nord-dark";
      };
    };
  };
}
