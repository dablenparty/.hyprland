#!/usr/bin/env zsh

setopt PIPE_FAIL

# NOTE: Tearing is still experimental and causes issues on monitors without VRR when mixing with mointors
# that DO have VRR. See: https://wiki.hypr.land/Configuring/Tearing/
declare -A bad_mondescs
bad_mondescs=(
  'Samsung Electric Company SAMSUNG 0x01000E00' true
)
hyprconf_path="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.conf"
echo "using config at $hyprconf_path"

handle() {
  # monitoraddedv2>>ID,PORT/NAME,DESCRIPTION
  case $1 in monitoraddedv2* | monitorremovedv2*)
    local tearing_value
    if [[ "${1%%>>*}" =~ ^monitoradded ]]; then
      tearing_value='false'
    else
      tearing_value='true'
    fi
    while IFS=, read -r monid monport mondesc; do
      is_bad="${${bad_mondescs[$mondesc]}:-false}"
      if $is_bad; then
        local tearing_verb monitor_verb
        if [[ "$tearing_value" == 'true' ]]; then
          monitor_verb="Lost"
          tearing_verb="enabling"
        else
          monitor_verb="Found"
          tearing_verb="disabling"
        fi
        notify-send --transient 'auto_tearing.zsh' "Detected monitor $mondesc, $tearing_verb tearing"
        echo "detected bad monitor $mondesc@$monport"
        echo "setting tearing to $tearing_value"
        sed -Ei --follow-symlinks "s/(\\s*allow_tearing\\s*=\\s*)(true|false)/\\1$tearing_value/" "$hyprconf_path"
      else
        echo "skipping"
      fi
    done <<<"${1#*>>}"
    ;;
  esac
}

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done
