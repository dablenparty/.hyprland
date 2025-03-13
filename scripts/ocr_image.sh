#!/usr/bin/env bash

# fail the script if any commands/pipes fail
set -euo pipefail

command_not_found() {
  # when using set -u, checking an arg with -n fails
  # -n assumes the var exists and can be checked as a string while
  # -z just checks if the var is empty or not
  if [[ -z "$1" ]]; then
    return 1
  fi

  command="$1"
  msg="'$command' not found"
  if [[ -z "$2" ]]; then
    body="Is it installed?"
  else
    body="Have you installed package '$2'?"
  fi

  echo "$msg. $body"
  notify-send -u critical "$msg" "$body"
}

if ! command -v upscayl >/dev/null 2>&1; then
  command_not_found 'upscayl' 'upscayl-ncnn'
  exit 1
elif ! command -v tesseract >/dev/null 2>&1; then
  command_not_found 'tesseract'
  exit 1
fi

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
