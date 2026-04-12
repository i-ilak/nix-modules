{
  pkgs,
  nixvim,
  inputs,
  flakeRoot ? inputs.self,
  ...
}:
let
  cli_tools = with pkgs; [
    fd # `find` alternative
    bat # is better than `cat`
    eza # Alternative to `ls`
    sd # More intuitive `sed`
    procs # Alternative to `ps`
    ripgrep # Fast and intuitive `grep`
    dust # Nicer version of `du`
    tealdeer # Show examples for executables from man pages
    bandwhich # Show network utilization
    grex # Create regex expression from provided examples
    comma # Run easily things from nixpkgs without first creating a shell
    hledger # double accounting
  ];

  developer_tools = with pkgs; [
    uv
    just
    ninja
    rustc
    cargo
    nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    llvmPackages_20.clang-unwrapped
  ];

  scripts = import (flakeRoot + /modules/shared/scripts.nix) { inherit pkgs; };
  shared_packages = cli_tools ++ developer_tools ++ scripts;
in
shared_packages
