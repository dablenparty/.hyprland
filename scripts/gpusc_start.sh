#!/usr/bin/env bash

set -eo pipefail

# TODO: cli args with getopts
# for passing args to gpu-screen-recorder, pass all args that come after '--'
OUTPUT_DEST="${OUTPUT_DEST:-/mnt/Recordings/GPUSC}"
declare -a GPUSC_ARGS

read -rep "Title (leave blank for default): " title

if [[ -z "$title" ]]; then
  title="Video"
fi

printf -v output_filename "%s/%s_%s.mp4" "$OUTPUT_DEST" "$title" "$(date +"%Y-%m-%d_%H-%M-%S")"
GPUSC_ARGS+=(-o "$output_filename")

capture_option="$(gpu-screen-recorder --list-capture-options | fzf --prompt="Capture Device:" | cut -d'|' -f1)"
GPUSC_ARGS+=(-w "$capture_option")

readarray -t selected_audio_apps < <(gpu-screen-recorder --list-application-audio | sort | fzf --multi --prompt="App Audio:")

for app in "${selected_audio_apps[@]}"; do
  GPUSC_ARGS+=(-a "$app Audio/app:$app")
done

selected_audio_devices=("Default Output/device:default_output" "Focusrite/alsa_input.usb-Focusrite_Scarlett_2i2_USB-00.HiFi__Mic1__source")

for dev in "${selected_audio_devices[@]}"; do
  GPUSC_ARGS+=(-a "$dev")
done

# construct command from dynamic args
GPUSC_ARGS=(
  gpu-screen-recorder
  -f 60
  -fm cfr
  -k hevc
  -bm qp
  -q very_high
  -tune performance
  -ac aac
  "${GPUSC_ARGS[@]}"
  "$@"
)

echo "GPUSC command: ${GPUSC_ARGS[*]}"

# TODO : extract utils.sh
read -rn 1 -p "Begin recording? [Y\n]" key
case $key in
y | Y | "") ;;
*)
  echo "aborting..."
  exit 1
  ;;
esac

systemd-inhibit --what "sleep:idle:shutdown" --who "gpu-screen-recorder" --why "recording screen" "${GPUSC_ARGS[@]}"
