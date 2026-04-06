_: {
  programs.lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim";
      gui = {
        nerdFontsVersion = "3";
        filterMode = "substring";
      };
      notARepository = "quit";
      git.pagers = [
        { pager = "delta --paging=never"; }
      ];
    };
  };
}
