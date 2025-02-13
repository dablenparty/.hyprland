#!/bin/bash
# taken from: https://adamsimpson.net/writing/getting-started-with-rofi

source="$(pactl list short sinks | cut -f 2 | rofi -i -dmenu -p "Change audio:")"
inputs="$(pactl list sink-inputs short | cut -f 1)"

for input in $inputs; do
  pactl move-sink-input "$input" "$source"
done

pactl set-default-sink "$source"
# TODO: get device.description for this instead
notify-send "Successfully set audio device" "$source"
