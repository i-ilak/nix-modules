{ pkgs }:

with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
in
shared-packages
++ [

  # Window manager, bar, background
  hyprland
  xwayland
  swaybg
  waybar

  # Security and authentication
  keepassxc

  # App and package management
  gnumake
  home-manager

  # Media and design tools
  vlc
  fontconfig
  font-manager

  # Messaging and chat applications
  discord

  # Testing and development tools
  rofi

  # Screenshot and recording tools
  flameshot

  # Text and terminal utilities
  feh # Manage wallpapers
  tree
  unixtools.ifconfig
  unixtools.netstat
  xorg.xrandr

  # File and system utilities
  inotify-tools # inotifywait, inotifywatch - For file system events
  libnotify
  xdg-utils

  # Other utilities
  firefox

  # PDF viewer
  zathura

  # Music and entertainment
  spotify
]
