#!/usr/bin/env bash

set -eo pipefail
# run last command of pipe in current shell, not a subshell
shopt -s lastpipe

# TODO: cli args with getopts
# for passing args to gpu-screen-recorder, pass all args that come after '--'
DEFAULT_MIC_SOURCE="alsa_input.usb-Focusrite_Scarlett_2i2_USB-00.HiFi__Mic1__source"
DEFAULT_TITLE="gpusc"
OUTPUT_DEST="${OUTPUT_DEST:-${XDG_VIDEOS_DIR:-$HOME/Videos}/GPUSC}"

if [[ ! -d "$OUTPUT_DEST" ]]; then
  mkdir -vp "$OUTPUT_DEST"
fi

while true; do
  read -rep "Title (leave blank for $DEFAULT_TITLE): " title

  if [[ -z "$title" ]]; then
    title="$DEFAULT_TITLE"
  fi

  printf -v output_filename "%s/%s_%(%F_%H-%M-%S)T.mp4" "$OUTPUT_DEST" "$title"
  if [[ -e "$output_filename" ]]; then
    printf "error: '%s' already exists!\n" "$output_filename" 1>&2
  else
    break
  fi
done

declare -a GPUSC_ARGS
GPUSC_ARGS+=(-o "$output_filename")

capture_option="${ gpu-screen-recorder --list-capture-options | fzf --prompt="Capture Device:"; }"
# only keep text before first pipe '|'
capture_option=${capture_option%%|*}
GPUSC_ARGS+=(-w "$capture_option")

# keys are track names, values are devices/apps
declare -A audio_track_map

# if any app is making sound, allow the user to select it from a list
audio_apps="${ gpu-screen-recorder --list-application-audio; }"
if [[ -n "$audio_apps" ]]; then
  while read -r app; do
    audio_track_map["$app App"]="app:$app"
  done <<<"${ printf "%s" "$audio_apps" | fzf --multi --prompt="App Audio:"; }"
fi

# otherwise, gpusc allows recording apps that haven't launched yet
while read -rep "Custom App Audio: " app && [[ -n "$app" ]]; do
  audio_track_map["$app App"]="app:$app"
done

declare -a audio_devices
i=1
# some devices should be selected by default, such as default_output and my mic
# keys are device ID's, values are the corresponding indices in $audio_devices
declare -A default_devices
default_devices["$DEFAULT_MIC_SOURCE"]=-1
default_devices["default_output"]=-1

# read all audio devices into an array while also checking if the device should
# be selected by default; if so, it's index is saved.
while read -r device; do
  # format: <device_id>|<name>
  device_id=${device%%|*}
  idx=${default_devices[$device_id]}
  if ((idx == -1)); then
    default_devices[$device_id]=$i
  fi
  audio_devices+=("$device")
  ((i++))
done <<<"${ gpu-screen-recorder --list-audio-devices; }"

fzf_args=(fzf --multi '--prompt=Audio Devices:' --delimiter '|' --with-nth 2)

# generate fzf select action for default devices
declare -a fzf_bind_actions
for device in "${!default_devices[@]}"; do
  idx=${default_devices[$device]}
  if ((idx == -1)); then
    continue
  fi
  fzf_bind_actions+=("pos($idx)" "toggle" "up")
done

# join actions with '+' as delimiter
if ((${#fzf_bind_actions} > 0)); then
  printf -v fzf_bind_arg "%s+" "${fzf_bind_actions[@]}"
  # trailing '+' is removed
  fzf_args+=(--sync --bind "start:${fzf_bind_arg:0:-1}")
fi

# select and pair audio devices with their tracks
while read -r device; do
  device_id="${device%%|*}"
  device_name="${device#*|}"
  audio_track_map["$device_name"]="$device_id"
done <<<"${ printf "%s\n" "${audio_devices[@]}" | "${fzf_args[@]}"; }"

printf "Recording video from %s\n" "$capture_option"

echo "Recording audio from:"
for track_name in "${!audio_track_map[@]}"; do
  device=${audio_track_map[$track_name]}
  # TODO: uncomment this when GPUSC re-implements audio track naming
  # removed in this commit: https://git.dec05eba.com/gpu-screen-recorder/commit/?id=0cdc3599318f05a820b3c936f83c98b4b3d11567
  # GPUSC_ARGS+=(-a "$track_name/$device")
  printf " - %s\n" "$track_name"
  GPUSC_ARGS+=(-a "$device")
done

printf -v combined_audio "%s|" "${audio_track_map[@]}"
# remove trailing '|'
combined_audio=${combined_audio:0:-1}

# construct command from dynamic args
GPUSC_ARGS=(
  gpu-screen-recorder
  # 60fps
  -f 60
  # constant framerate
  -fm cfr
  # video encoder
  -k hevc_10bit
  # constant quality bitrate
  -bm qp
  # full color range
  -cr full
  # very high quality
  -q very_high
  # set multipass, b frames, preset for NVIDIA
  -tune quality
  # audio encoder (I have issues with opus)
  -ac aac
  # TODO: see TODO above about audio track names
  # -a "Combined/$combined_audio"
  -a "$combined_audio"
  "${GPUSC_ARGS[@]}"
  "$@"
)

printf "GPUSC command: %s\n" "${GPUSC_ARGS[*]}"

# TODO : extract utils.sh
read -rn 1 -p "Begin recording? [Y\n]" key
# print a newline because read doesn't
echo
case $key in
y | Y | "") ;;
*)
  echo "aborting..."
  exit 1
  ;;
esac

exec systemd-inhibit --what "sleep:idle:shutdown" --who "${0##*/}" --why "recording screen ($capture_option)" "${GPUSC_ARGS[@]}"
