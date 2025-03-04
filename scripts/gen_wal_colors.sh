#!/usr/bin/env bash

if (($# != 1)); then
  echo "usage: $0 <wallpaper_file>"
fi

wallpaper_file="$1"

# args must be separated for wal
wal --cols16 -q -t -s -n -i "$wallpaper_file"

# sets $wallpaper to the absolute path of the current wallpaper
source "$HOME/.cache/wal/colors.sh"
wallpaper="${wallpaper:-wallpaper_file}"

notify-send -u normal --app-name swww-daemon "Updated wallpaper colors!" "${wallpaper##*/}"
