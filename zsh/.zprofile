if uwsm check may-start; then
  # exits with code 2 on timeout
  read -t 3 -r -q "key?Start Hyprland? [y\\N] "
  case $? in
  0 | 2)
    exec uwsm start hyprland.desktop
    ;;
  *) ;;
  esac
else
  echo "error: uwsm check failed with exit code $?" 1>&2
fi
