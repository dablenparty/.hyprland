#!/usr/bin/env zsh

set -e
setopt PIPE_FAIL

hyprconf_dir="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
monitor_dir="$hyprconf_dir/monitors"
transform_num=${1:-0}

# get the currently focused monitor with jq and locate its config file with rg
# this should only ever return one filename
current_monitor_conf=${$(rg -l "output\s*=\s*\"desc:$(hyprctl monitors -j | jq --raw-output ".[] | select(.focused) | .description")\"" "$monitor_dir"/*.lua)##*/}
env mon.zsh rotate $current_monitor_conf $transform_num
