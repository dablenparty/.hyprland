#!/usr/bin/env bash

# don't launch multiple instances of hyprlock
# WARN: don't use pkill here, otherwise that'd defeat the purpose of a lock screen
if [[ -n "${ pidof hyprlock; }" ]]; then
  exit 0
fi

# select a random placeholder and insert it into the config file
placeholder="${ shuf -n 1 "$HOME/.config/hypr/.password_placeholders.txt"; }"
sed -i -E "s/(placeholder_text\s*=)\s*(<i>.+<\/i>)/\1 <i>$placeholder<\/i>/g" "$HOME/.config/hypr/hyprlock.conf"

# lock up with grace since it's not supported as a config key anymore (why???)
uwsm app -- hyprlock --grace 4
# after unlock...
