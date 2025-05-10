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

# keys are track names, values are devices
declare -A audio_track_map

while read -r app; do
  audio_track_map["$app Audio"]="app:$app"
done < <(gpu-screen-recorder --list-application-audio | sort | fzf --multi --prompt="App Audio:")

audio_track_map["Focusrite"]="device:alsa_input.usb-Focusrite_Scarlett_2i2_USB-00.HiFi__Mic1__source"
audio_track_map["Default Output"]="default_output"

for key in "${!audio_track_map[@]}"; do
  value=${audio_track_map[$key]}
  # TODO: uncomment this when GPUSC re-implements audio track naming
  # removed in this commit: https://git.dec05eba.com/gpu-screen-recorder/commit/?id=0cdc3599318f05a820b3c936f83c98b4b3d11567
  # GPUSC_ARGS+=(-a "$key/$value")
  GPUSC_ARGS+=(-a "$value")
done

printf -v combined_audio "%s|" "${audio_track_map[@]}"
# remove trailing '|'
combined_audio=${combined_audio:0:-1}

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
  # TODO: see TODO above about audio track names
  # -a "Combined/$combined_audio"
  -a "$combined_audio"
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
