#!/usr/bin/env zsh

set -e
setopt pipefail

hyprconf_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
active_monitor_dir="$hyprconf_dir/monitors/active"

print_help() {
  print 'usage: mon <enable|disable> [monitor-slug]'
}

check_enabled() {
  fd -q "${1:?missing argument}(\.conf)?$" "$hyprconf_dir/monitors/active"
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

# enable | disable
cmd="$1"
# FIXME: completion funcs because typing the slugs is a pain and this below isn't very ergonomic
monitor="${2:-$(print "${(@kFQ)all_monitors}" | fzf --prompt="Monitor: ")}"

# WARN: without --follow-symlinks, sed replaces symlinks with a file.
# see: https://unix.stackexchange.com/a/192017
case "$cmd" in
enable)
  if check_enabled "$monitor"; then
    printf '%s is already enabled!\n' "$monitor"
    exit 0
  fi
  # relative link
  ln -vs "../$monitor" "$active_monitor_dir/$monitor.conf"
  hyprctl reload
  ;;
disable)
  if ! check_enabled "$monitor"; then
    printf "%s is already disabled!\n" "$monitor"
    exit 0
  fi
  rm -v "$active_monitor_dir/$monitor.conf"
  hyprctl reload
  ;;
*)
  printf "error: unknown command '%s'\n" "$cmd"
  exit 2
  ;;
esac
