_: {
  imports = [
    ./editor.nix
    ./languages
  ];

  programs.helix = {
    enable = true;
  };
}
