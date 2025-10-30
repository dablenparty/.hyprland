#!/usr/bin/env zsh

set -e
setopt pipefail

hyprconf_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
active_monitor_dir="$hyprconf_dir/monitors/active"

print_help() {
  print 'usage: mon <enable|disable|show> [monitor-slug]'
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

cmd="$1"
# remove .conf from end if it's there
monitor="${2%.conf}"

# WARN: without --follow-symlinks, sed replaces symlinks with a file.
# see: https://unix.stackexchange.com/a/192017
case "$cmd" in
enable)
  if check_enabled "$monitor"; then
    printf '%s is already enabled!\n' "$monitor"
    exit 0
  fi
  # relative link
  ln -vs "../$monitor.conf" "$active_monitor_dir/$monitor.conf"
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
show)
  # TODO: show [active]: shows all/active monitor confs
  echo "error: not yet implemented"
  exit 3
  ;;
*)
  printf "error: unknown command '%s'\n" "$cmd"
  exit 2
  ;;
esac
