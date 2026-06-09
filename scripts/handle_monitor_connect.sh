#!/usr/bin/env sh

handle() {
  case $1 in monitoradded*)
    hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 1, monitor = "desc:ASUSTek COMPUTER INC ROG PG278QR #ASORhydAMyjd" })'
    hyprctl dispatch 'hl.dsp.workspace.move({ workspace = 2, monitor = "desc:Samsung Electric Company LC27G7xT H4ZTB01524" })'
    ;;
  esac
}

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do handle "$line"; done
