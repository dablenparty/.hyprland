#!/bin/bash
# taken from: https://adamsimpson.net/writing/getting-started-with-rofi

declare -A sources
i=0
while read -r line; do
  # if the line is empty, end this section and continue
  if [[ "$line" =~ ^\s*$ ]]; then
    i=$((i + 1))
    continue
  fi
  sources[$i]="${sources[$i]}\n$line"
done < <(pactl list sinks)

declare -A source_names
for i in $(seq 0 "$i"); do
  # TODO: if sink starts with 'raop_sink', label it as (AirPlay)
  source_names[$i]="$(echo -e "${sources[$i]}" | rg 'Description: ' | awk -F ': ' '{print $2}')"
  i=$((i + 1))
done

selected_idx="$(for i in $(seq 0 ${#source_names[@]}); do echo "${source_names[$i]}"; done | rofi -dmenu -format "i" -i -p "Change audio:")"

if [[ -z "$selected_idx" ]]; then
  exit 0
fi

source="${sources[$selected_idx]}"
source_name="${source_names[$selected_idx]}"
sink="$(echo -e "$source" | rg 'Name: ' | awk -F ': ' '{print $2}')"

printf "Selected Audio Device Index: %d\nName: %s\nSink: %s\n" "$selected_idx" "$source_name" "$sink"

inputs="$(pactl list sink-inputs short | cut -f 1)"

for input in $inputs; do
  pactl move-sink-input "$input" "$sink"
done

pactl set-default-sink "$sink"
notify-send "Successfully set audio device" "$source_name"
