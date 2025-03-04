#!/usr/bin/env bash

if (($# == 1)); then
  wallpaper_root="$(realpath -e "$1")"
else
  wallpaper_root="$HOME/Pictures/Wallpapers/"
fi

# args must be separated for wal
wal --cols16 -q -t -s -n -i "$wallpaper_root"

# load pywal colorscheme
# sets $wallpaper to the absolute path of the current wallpaper
source "$HOME/.cache/wal/colors.sh"

swww img --resize crop --transition-type any --transition-fps 120 --transition-duration 1.35 "$wallpaper"

# get the filename by removing the root

notify-send -u normal --app-name swww-daemon "Updated wallpaper and colors!" "${wallpaper##*/}"
