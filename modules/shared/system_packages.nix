{
  pkgs,
  ...
}:
with pkgs;
[
  # General packages for development and system management
  bash-completion
  coreutils
  killall
  openssh
  wget
  zip
  colordiff
  uv
  nixpkgs-fmt
  grc
  nixos-anywhere
  sshpass

  # Encryption and security tools
  gnupg
  libfido2
  libiconv

  # Media-related packages
  font-awesome
  meslo-lgs-nf

  # Text and terminal utilities
  htop
  jq
  ripgrep
  tree
  unzip
  zsh-powerlevel10k
  lazygit
]
