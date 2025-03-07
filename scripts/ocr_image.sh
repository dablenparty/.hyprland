#!/usr/bin/env bash

if (($# != 1)); then
  echo "usage: $0 <image_file>"
fi

notif_id="$(notify-send --print-id --urgency low --expire-time 10000 "Processing OCR...")"
# upscale image
upscaled_path="${1%/*}/upscaled_${1##*/}"
# TODO: notify of errors
upscayl -i "$1" -o "$upscaled_path"
wl-copy "$(tesseract "$upscaled_path" stdout)"
notify-send --urgency normal --replace-id "$notif_id" "Copied OCR to clipboard!"
