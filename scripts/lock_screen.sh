#!/usr/bin/env bash

# don't launch multiple instances of mpvlock
# WARN: don't use pkill here, otherwise that'd defeat the purpose of a lock screen
if [[ -n "$(pidof mpvlock)" ]]; then
  exit 0
fi

# select a random placeholder and insert it into the config file
placeholder="$(shuf -n 1 "$HOME/.config/hypr/.password_placeholders.txt")"
sed -i -E "s/(placeholder_text\s*=)\s*(<i>.+<\/i>)/\1 <i>$placeholder<\/i>/g" "$HOME/.config/mpvlock/mpvlock.conf"

# lock up
uwsm app -- mpvlock
# after unlock...
# TODO: this is kinda nuclear, find another solution
pkill -x mpvpaper
