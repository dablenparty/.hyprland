#!/usr/bin/env zsh

typeset -A commands_to_inhibit=(
  [ffmpeg]="en/decoding video"
  [makemkvcon]="ripping DVD/Blu-Ray"
  [paru]="updating system"
)

for cmd reason in "${(@kv)commands_to_inhibit}"; do
  # WARN: use absolute path to executable, otherwise risk recursive aliases
  cmd_path="$(command -v "$cmd")"
  alias "$cmd"="systemd-inhibit --no-pager --who '$cmd' --what 'shutdown:sleep:idle' --why '$reason' $cmd_path"
done
