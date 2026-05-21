#!/usr/bin/env zsh

set -e
setopt PIPE_FAIL
setopt EXTENDED_GLOB

hyprconf_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"

print_help() {
  print 'usage: mon <enable|disable|primary|rotate> [monitor-conf]'
}

check_enabled() {
  rg -q "${1:?missing argument}" "$hyprconf_dir/monitors/active.lua"
  return $?
}

is_hyprland() {
  [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]
  return $?
}

if (($# < 1)); then
  print_help 1>&2
  exit 2
fi

declare -A all_monitors
for file in $hyprconf_dir/monitors/*.lua; do
  mon_name="$file:t:r"
  if [[ $mon_name == "active" ]]; then
    continue
  fi
  all_monitors["$mon_name"]=$file
done

cmd="$1"
monitor="${2%.lua}"

case "$cmd" in
  enable)
    if check_enabled "$monitor"; then
      printf '%s is already enabled!\n' "$monitor"
      exit 0
    fi
    # enable
    echo "require(\"monitors.$monitor\")" >> "$hyprconf_dir/monitors/active.lua"
    if is_hyprland; then
      hyprctl reload
    fi
    ;;
  disable)
    if ! check_enabled "$monitor"; then
      printf "%s is already disabled!\n" "$monitor"
      exit 0
    fi
    sed -Ei --follow-symlinks "/$monitor/d" "$hyprconf_dir/monitors/active.lua"
    if is_hyprland; then
      hyprctl reload
    fi
    ;;
  primary)
    if [[ -z "$monitor" ]]; then
      # rg exits 1 if it fails to match
      set +e
      xrandr_monitor="${$(xrandr --listactivemonitors | rg --color=never -IN ' \d: \+\*([\w\d-]+).*' --replace '$1'):-none set}"
      if [[ -r "$HOME/.primary_monitor" ]]; then
        my_monitor="${$(<"$HOME/.primary_monitor"):-none set}"
      else
        my_monitor="none set"
      fi
      printf '  your primary monitor: %s\nxrandr primary monitor: %s\n' $my_monitor $xrandr_monitor
      exit 0
    fi

    monitor_conf=${all_monitors["$monitor"]}
    monitor_description="$(rg --color=never -IN '\s*output\s*=\s*"((desc:)?.+?)",$' --replace '$1' "$monitor_conf")"
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
  reload)
    mon.zsh disable "$monitor" && mon.zsh enable "$monitor"
    if is_hyprland; then
      hyprctl reload
    fi
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
      sed_cmd="/}/i \\    transform = $transform_value,"
    fi
    sed -Ei --follow-symlinks "$sed_cmd" "$monitor_conf"

    if is_hyprland; then
      hyprctl reload
    fi
    ;;
  *)
    printf "error: unknown command '%s'\n" "$cmd"
    exit 2
    ;;
esac
