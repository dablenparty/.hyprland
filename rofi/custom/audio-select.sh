#!/usr/bin/env bash

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
  sources[$i]="${sources[$i]}\n$line"
done < <(pactl list sinks)

source_count=$((${#sources[@]} - 1))

# initialize sinks and names from parsed sources
for i in $(seq 0 "$source_count"); do
  source="${sources[$i]}"
  sinks[$i]="$(echo -e "$source" | rg 'Name: ' | awk -F ': ' '{print $2}')"
  source_names[$i]="$(echo -e "$source" | rg 'Description: ' | awk -F ': ' '{print $2}')"

  # if sink starts with 'raop_sink', label it as (AirPlay)
  if [[ "${sinks[$i]}" =~ ^raop_sink.+$ ]]; then
    source_names[$i]="${source_names[$i]} (AirPlay)"
  fi

  # increment i
  i=$((i + 1))
done

selected_idx="$(for i in $(seq 0 "$source_count"); do echo "${source_names[$i]}"; done | rofi -dmenu -format "i" -i -p "Change audio:")"

if [[ -z "$selected_idx" ]]; then
  exit 0
fi

source="${sources[$selected_idx]}"
source_name="${source_names[$selected_idx]}"
sink="${sinks[$selected_idx]}"

printf "Selected Source Index: %d\nName: %s\nSink: %s\n" "$selected_idx" "$source_name" "$sink"

inputs="$(pactl list sink-inputs short | cut -f 1)"

for input in $inputs; do
  pactl move-sink-input "$input" "$sink"
done

pactl set-default-sink "$sink"
notify-send "Successfully set audio device" "$source_name"
