#!/usr/bin/env bash

if (($# == 1)); then
  wallpaper_root="${ realpath -e "$1"; }"
else
  wallpaper_root="$HOME/Pictures/Wallpapers/"
fi

# args must be separated for wal
gen_wal_colors.sh "$wallpaper_root"

# load $wallpaper
source "$HOME/.cache/wal/colors.sh"
wallpaper="${wallpaper:-wallpaper_root}"

swww img --resize crop --transition-type any --transition-fps 120 --transition-duration 1.35 "$wallpaper"
