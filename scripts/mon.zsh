#!/usr/bin/env zsh

set -e
setopt PIPE_FAIL

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
  conf_name="${${conf##*/}%.*}"
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
primary)
  monitor_conf=${all_monitors["$monitor"]}
  monitor_description="$(rg --color=never -IN '\s*output\s*=\s*((desc:)?.+)$' --replace '$1' "$monitor_conf")"
  if [[ $monitor_description =~ ^desc:(.+)$ ]]; then
    output="$(hyprctl monitors -j | jq -r ".[] | select(.description == \"${match[1]}\") | .name")"
  else
    output="$monitor_description"
  fi
  printf 'setting primary to %s (%s)\n' "$monitor_description" "$output"
  xrandr --output "$output" --primary
  # no newline
  printf '%s' "$output" > "$HOME/.primary_monitor"
  ;;
rotate)
  monitor_conf=${all_monitors["$monitor"]}
  transform_value=$3
  # checks for uncommented line
  if rg -q '^\s*transform' "$monitor_conf"; then
    # already has transform line; modify it
    sed_cmd="s/(\s*transform\s*=\s*)[0-9]/\1$transform_value/"
  else
    # doesn't have transform line; add it at the bottom
    sed_cmd="/}/i \\    transform = $transform_value"
  fi
  sed -Ei --follow-symlinks "$sed_cmd" "$monitor_conf"
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
