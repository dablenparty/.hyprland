#!/usr/bin/env bash

show_help() {
  printf "usage: %s -fh <src> [dest]\n" "$0" 1>&2
  printf "  -h    show this help\n" 1>&2
  printf "  -n    noclobber (don't overwrite files)\n" 1>&2
  printf "  -f    force overwrite file\n" 1>&2
}

set -e

if [ -z "$OPTIND" ]; then
  OPTIND=1
fi

option_force=false
option_noclobber=false

while getopts "fhn" opt; do
  case $opt in
  f)
    option_force=true
    ;;
  h)
    show_help
    exit 0
    ;;
  n)
    option_noclobber=true
    ;;
  ?)
    printf "Invalid option: -%s\n" "$OPTARG" 1>&2
    exit 1
    ;;
  esac
done

# move processed args out
shift $((OPTIND - 1))

if (($# < 1)); then
  show_help
  exit 1
fi

# -e is a GNU option
input_file="${ realpath -e "$1"; }"
if [[ -n "$2" ]]; then
  output_file="$2"
else
  output_file="${input_file%.*}.mp4"
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg not found! Make sure it is installed and on the \$PATH" >&2
  exit 1
fi

if [[ $option_noclobber = true && -e $output_file ]]; then
  printf "failed to remux %s: %s already exists\n" "$input_file" "$output_file" 1>&2
  exit 1
fi

extra_ffmpeg_args=()
if [[ $option_force = true ]]; then
  extra_ffmpeg_args+=(-y)
fi

# -map 0: select all streams from input 0
# -c copy: copy audio/video codecs
# This "remuxes" by copying the audio and video data into a new container instead
# of re-encoding it, dramatically speeding up the process and reducing CPU/GPU
# usage. This assumes, however, that the input file streams are encoded using
# MP4-compatible encoders, such as H.264, HEVC, etc..
# -tag:v hvc1: sets the HEVC encoder to hvc1 because Final Cut Pro doesn't support hev1
systemd-inhibit --who "ffmpeg" --what idle:sleep --why "remuxing $input_file" ffmpeg "${extra_ffmpeg_args[@]}" -i "$input_file" -map 0 -c:v hevc_nvenc -c:a aac -preset p7 -tune lossless -tag:v hvc1 "$output_file"
