{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.infra.host) homeDir sshAuthSock;
in
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting

      # As of fish 4.3, fish_key_bindings is no longer set in universal scope
      # by default — declare it explicitly as a global so the binding is
      # managed by Nix and fish's one-shot conf.d migration shim
      # (~/.config/fish/conf.d/fish_frozen_key_bindings.fish) is unnecessary.
      set -g fish_key_bindings fish_default_key_bindings

      set -x FZF_DEFAULT_COMMAND "fd . $HOME"
      set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
      set -x FZF_ALT_C_COMMAND "fd -t d . $HOME"
      set -x GID "$(id -g)"
      set -x EDITOR "nvim"
    ''
    + (lib.optionalString (sshAuthSock != null) ''
      set -x SSH_AUTH_SOCK ${sshAuthSock}
    '');
    plugins = [
      {
        name = "grc";
        inherit (pkgs.fishPlugins.grc) src;
      }
      {
        name = "z";
        inherit (pkgs.fishPlugins.z) src;
      }
      {
        name = "fzf";
        inherit (pkgs.fishPlugins.fzf) src;
      }
      {
        name = "fzf-fish";
        inherit (pkgs.fishPlugins.fzf-fish) src;
      }
      {
        name = "pisces";
        inherit (pkgs.fishPlugins.pisces) src;
      }
      {
        name = "tide";
        inherit (pkgs.fishPlugins.tide) src;
      }
      {
        name = "plugin-git";
        inherit (pkgs.fishPlugins.plugin-git) src;
      }
    ];
    shellAliases = {
      vim = "nvim";
      ip = "ip --color=auto";
      ll = "eza -l";
      ls = "eza -g";
      tree = "eza -T";
      mkdir = "mkdir -p";
      diff = "colordiff --nobanner";
      df = "df -Tha --total";
      du = "du -h";
      ps = "procs";
      flame = "flameshot gui";
    };
    shellInitLast = ''
      set -gx PATH ${homeDir}/.cargo/bin $PATH
    '';
  };
}
