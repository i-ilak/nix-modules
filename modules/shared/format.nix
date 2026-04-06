_: {
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    yamlfmt.enable = true;
  };
  settings.global.excludes = [
    "*.md"
    "LICENSE"
    ".envrc"
  ];
}
