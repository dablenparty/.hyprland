#!/usr/bin/env bash

set -eo pipefail

declare -A sources
declare -A source_names
declare -A sinks

# parse source sections from pactl output (separated by blank lines)
i=0
while read -r line; do
  # if the line is empty, end this section and continue
  if [[ "$line" =~ ^\s*$ ]]; then
    i=$((i + 1))
    continue
  fi
  # add a newline (writing \n writes the LITERAL \n)
  sources[$i]="${sources[$i]}
$line"
done < <(pactl list sinks)

source_count=$((${#sources[@]}))

# initialize sinks and names from parsed sources
for ((i = 0; i < source_count; i++)); do
  while read -r line; do
    # if the regex doesn't match, continue
    [[ "$line" =~ (Description|Name):\ ?(.+)$ ]] || continue

    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"

    case "$key" in
    Description)
      # the sink type can be extracted from the start of the sink name
      # remove everything after first . (e.g. "one.two.three" -> "one")
      sink_type="${sinks[$i]%%.*}"

      case "$sink_type" in
      raop_sink)
        source_names[$i]="$value (AirPlay)"
        ;;
      bluez_output)
        source_names[$i]="$value (Bluetooth)"
        ;;
      *)
        source_names[$i]="$value"
        ;;
      esac
      ;;
    Name)
      sinks[$i]="$value"
      ;;
    *) ;;
    esac
  done <<<"${sources[$i]}"

done

selected_idx="${ printf "%s\n" "${source_names[@]}" | rofi -dmenu -format "i" -i -p "Audio Device:"; }"

if [[ -z "$selected_idx" ]]; then
  exit 0
fi

source_name="${source_names[$selected_idx]}"
sink="${sinks[$selected_idx]}"

printf "Selected Source Index: %d\nName: %s\Description: %s\n" "$selected_idx" "$sink" "$source_name"

inputs="${ pactl list sink-inputs short | cut -f 1; }"

for input in $inputs; do
  pactl move-sink-input "$input" "$sink"
done

pactl set-default-sink "$sink"
notify-send "Successfully set audio device" "$source_name"
