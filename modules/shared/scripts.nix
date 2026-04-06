{
  pkgs,
  ...
}:
let
  copy = pkgs.writeShellScriptBin "copy" ''
    #!${pkgs.bash}/bin/bash
    set -e
    set -u

    if hash pbcopy 2>/dev/null; then
      exec pbcopy
    elif hash xclip 2>/dev/null; then
      exec xclip -selection clipboard
    elif hash putclip 2>/dev/null; then
      exec putclip
    else
      rm -f /tmp/clipboard 2> /dev/null
      if [ $# -eq 0 ]; then
        cat > /tmp/clipboard
      else
        cat "$1" > /tmp/clipboard
      fi
    fi
  '';

  pasta = pkgs.writeShellScriptBin "pasta" ''
    #!${pkgs.bash}/bin/bash
    set -e
    set -u

    if hash pbpaste 2>/dev/null; then
      exec pbpaste
    elif hash xclip 2>/dev/null; then
      exec xclip -selection clipboard -o
    elif [[ -e /tmp/clipboard ]]; then
      exec cat /tmp/clipboard
    else
      echo ""
    fi
  '';

  pastas = pkgs.writeShellScriptBin "pastas" ''
    #!${pkgs.bash}/bin/bash
    set -e
    set -u
    set -o pipefail

    trap 'exit 0' SIGINT

    last_value=""

    while true
    do
      value="$(pasta)"

      if [ "$last_value" != "$value" ]; then
        echo "$value"
        last_value="$value"
      fi

      sleep 0.1
    done
  '';

  scripts = [
    copy
    pasta
    pastas
  ];
in
scripts
