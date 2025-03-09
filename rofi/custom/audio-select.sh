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
      # if sink starts with 'raop_sink', label it as (AirPlay)
      if [[ "${sinks[$i]}" =~ ^raop_sink ]]; then
        source_names[$i]="$value (AirPlay)"
      else
        source_names[$i]="$value"

      fi
      ;;
    Name)
      sinks[$i]="$value"
      ;;
    *) ;;
    esac
  done <<<"${sources[$i]}"

done

selected_idx="$(for ((i = 0; i < source_count; i++)); do echo "${source_names[$i]}"; done | rofi -dmenu -format "i" -i -p "Audio Device:")"

if [[ -z "$selected_idx" ]]; then
  exit 0
fi

source_name="${source_names[$selected_idx]}"
sink="${sinks[$selected_idx]}"

printf "Selected Source Index: %d\nName: %s\Description: %s\n" "$selected_idx" "$sink" "$source_name"

inputs="$(pactl list sink-inputs short | cut -f 1)"

for input in $inputs; do
  pactl move-sink-input "$input" "$sink"
done

pactl set-default-sink "$sink"
notify-send "Successfully set audio device" "$source_name"
