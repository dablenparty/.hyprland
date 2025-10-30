#compdef mon.zsh

_mon() {
  _arguments -s -S -C : \
    '1:command:((enable\:"Enable a monitor"
disable\:"Disable a monitor"))' \
    '2:conf file:_files -W "$HOME/.config/hypr/monitors" -g "*.conf"' &&
    ret=0
}

_mon_comp() {
  case "$service" in
  mon.zsh)
    _mon "$@"
    ;;
  *)
    _message "Error"
    ;;
  esac
}

_mon_comp "$@"
