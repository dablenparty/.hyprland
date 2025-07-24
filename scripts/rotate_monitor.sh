#!/usr/bin/env bash

set -eo pipefail

transform_num=${1:-0}

# get the port ID for the currently focused monitor
current_monitor="${ hyprctl monitors -j | jq --raw-output ".[] | select(.focused) | .name"; }"
notify-send -u critical "Failed to rotate $current_monitor" 'Monitor syntax has updated. Please fix the script!'
