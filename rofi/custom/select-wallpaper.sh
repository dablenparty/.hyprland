#!/usr/bin/env bash

wallpaper_root="$HOME/Pictures/Wallpapers"

if [[ ! -d "$wallpaper_root" ]]; then
  printf "Could not find wallpaper directory '%s'" "$wallpaper_root"
  exit 1
fi

# read into an array for index access later
readarray -t all_files <<<"$(fd -tf --color=never --absolute-path . "$wallpaper_root")"
selected_idx="$(for p in "${all_files[@]}"; do echo -en "$(basename "$p")\0icon\x1f$p\n"; done | rofi -dmenu -format "i" -i -show-icons -p "Wallpaper")"

if [[ -z "$selected_idx" ]]; then
  exit 0
fi

"$HOME/update-wallpaper.sh" "${all_files[$selected_idx]}" &>/dev/null
