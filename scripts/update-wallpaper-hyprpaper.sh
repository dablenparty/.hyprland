#!/bin/bash

wallpaper_root="$HOME/Pictures/Wallpapers/"

if (($# == 1)); then
  # use the file passed in
  file_name="$(basename "$1")"
  wallpaper_root="$wallpaper_root/$file_name"
fi

# args must be separated for wal
wal --cols16 -q -t -s -n -i "$wallpaper_root"

# load pywal colorscheme
source "$HOME/.cache/wal/colors.sh"

hyprctl hyprpaper unload all
# $wallpaper should be loaded by the above script
hyprctl hyprpaper preload "$wallpaper"
# set globally
hyprctl hyprpaper wallpaper ",$wallpaper"

# get the filename by removing the root

notify-send -u normal --app-name hyprpaper "Successfully updated wallpaper and colors!" "Used $(basename "$wallpaper")"
