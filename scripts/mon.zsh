#!/usr/bin/env zsh

set -e
setopt pipefail

hyprconf_dir="$HOME/.config/hypr"

print_help() {
  print 'usage: mon <enable|disable> [gpu-port]'
}

function check_disabled {
  rg -q "monitor.*${1:?missing argument gpu_port},disable" "$hyprconf_dir"/monitors.conf
  return $?
}

if (($# < 1)); then
  print_help 1>&2
  exit 2
fi

declare -A all_monitors
for conf in "$hyprconf_dir"/monitors/*.conf; do
  conf_name="${conf##*/}"
  conf_name="${conf_name%.*}"
  all_monitors["$conf_name"]="$conf"
done

cmd="$1"
# TODO: pretty fzf
gpu_port="${2:-$(print "${(@kFQ)all_monitors}" | fzf --prompt="Monitor: ")}"
# TODO: verify gpu port has a config

# sed can comment/uncomment with properly crafted find & replace commands (s// commands)
# removing the line is harder
source_pattern="source.*monitors\/$gpu_port\.conf$"
disable_pattern="monitor.*$gpu_port,disable"

# WARN: without --follow-symlinks, sed replaces symlinks with a file.
# see: https://unix.stackexchange.com/a/192017
case "$cmd" in
enable)
  if ! check_disabled "$gpu_port"; then
    printf '%s is already enabled!'
    exit 0
  fi
  sed -Ei --follow-symlinks "/$disable_pattern/d; s/^#.*($source_pattern)/\1/" "$hyprconf_dir"/monitors.conf
  hyprctl reload
  ;;
disable)
  if check_disabled "$gpu_port"; then
    printf "%s is already disabled!\n" "$gpu_port"
    exit 0
  fi
  sed -Ei --follow-symlinks "s/$source_pattern/# \0/; /$source_pattern/a monitor = $gpu_port,disable" "$hyprconf_dir"/monitors.conf
  hyprctl reload
  ;;
*)
  printf "error: unknown command '%s'\n" "$cmd"
  exit 2
  ;;
esac
