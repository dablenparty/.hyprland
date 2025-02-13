#!/bin/bash

# wait for the y key, returning 0 when it is pressed
wait_for_y_key() {
  if [[ -n "$1" ]]; then
    prompt="$1"
  else
    prompt="Would you like to continue? [Y\n]"
  fi
  read -p "$prompt" -r -s -n 1 key
  printf '\n'

  case $key in
  y | Y | "") return 0 ;;
  n | N)
    return 1
    ;;
  *)
    return 1
    ;;
  esac
}

# TODO: colors
echo 'Checking Hyprland for update...'

if (($# == 1)); then
  hyprland_path=$1
elif (($# > 1)); then
  echo 'usage: update_hyprland.sh [HYPRLAND_PATH]'
  exit 1
else
  hyprland_path="$HOME/Hyprland/"
fi

if [[ ! -e "$hyprland_path/.git" ]]; then
  echo "Failed to locate valid git repository at '$hyprland_path', make sure you cloned it properly!"
  exit 1
fi

# cd into Hyprland and fetch from the remote
cd "$hyprland_path" || (printf "Failed to cd into %s" "$hyprland_path" && exit 1)
git fetch --all

hyprland_match_count="$(git remote get-url origin | rg --color=never --count 'Hyprland' || echo 0)"
# if the remote URL doesn't include the word 'Hyprland', it's probably not the right folder
if (("$hyprland_match_count" < 1)); then
  echo "Could not find Hyprland fetch url in '$hyprland_path'"
  exit 1
fi

# Get the current branch name
local_branch="$(git rev-parse --abbrev-ref HEAD)"

# Construct the upstream branch name
upstream_branch="origin/$local_branch"

# Check if there are updates available by comparing commit hashes
latest_commit_local="$(git rev-parse HEAD)"
latest_commit_remote="$(git rev-parse "$upstream_branch")"

if [[ "$latest_commit_remote" == "$latest_commit_local" ]]; then
  echo 'Hyprland is up-to-date!'
  exit 0
fi

diff_count="$(git rev-list --count "$upstream_branch" --not "$local_branch")"
echo "You are $diff_count commits behind"

if ! wait_for_y_key "Would you like to update? [Y\n]"; then
  exit 0
fi

if wait_for_y_key "Update dependencies? [Y\n]"; then
  echo 'Updating dependencies'
  # if this gets out-of-date, check the list in your Obsidian vault or the Hyprland docs
  paru -S --needed --asdeps cairo \
    cmake \
    cpio \
    gcc \
    glaze \
    hyprcursor-git \
    hyprgraphics-git \
    hyprlang-git \
    hyprutils-git \
    hyprwayland-scanner-git \
    libdisplay-info \
    libinput \
    libliftoff \
    libx11 \
    libxcb \
    libxcomposite \
    libxfixes \
    libxkbcommon \
    libxrender \
    meson \
    ninja \
    pango \
    pixman \
    tomlplusplus \
    wayland-protocols \
    xcb-proto \
    xcb-util \
    xcb-util-errors \
    xcb-util-keysyms \
    xcb-util-wm \
    xorg-xwayland

  paru -S --needed --asexplicit aquamarine-git \
    egl-wayland \
    kitty \
    hyprpolkitagent-git \
    qt5-wayland \
    qt6-wayland \
    seatd \
    uwsm \
    xdg-desktop-portal-hyprland-git
fi

echo 'Updating Hyprland'
git pull origin "$local_branch" || exit 1
git submodule update --remote --recursive --rebase || exit 1
make all
sudo make install

date_str="BUILD_COMMIT $(date +"%a %b %d %Y %H-%M-%S")"
git rev-parse HEAD >"$hyprland_path/$date_str"
echo 'Successfully updated and installed Hyprland!'
