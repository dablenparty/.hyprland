#!/usr/bin/env bash

set -eo pipefail

transform_num=${1:-0}

# get the port ID for the currently focused monitor
current_monitor="$(hyprctl monitors -j | jq --raw-output ".[] | select(.focused) | .name")"
# WARN: this requires the monitor to be defined in the config
# get existing rule for focused monitor from config
# TODO: add handling for when the monitor is not in the config
og_monitor_rule="$(rg --color=never -IN "^monitor=($current_monitor.+)$" --replace '$1' "$HOME/.config/hypr/monitors.conf")"

if ((transform_num == 0)); then
  # reset
  monitor_rule="$og_monitor_rule"
else
  # rotate (transform) monitor
  monitor_rule="${og_monitor_rule},transform,$transform_num"
fi

# actually execute transform
hyprctl keyword monitor "$monitor_rule"
