#!/usr/bin/env bash

set -e

paru --rebuild=all --sudoloop -S blueman \
  boxunbox \
  devtools \
  dot-hyprland/hypridle-git \
  firefox \
  foot \
  hyprlock-git \
  hyprshot-git \
  keyd \
  mako \
  mpvpaper \
  obsidian \
  perl-image-exiftool \
  python-pywal16 \
  rofi-wayland \
  sddm \
  seatd \
  socat \
  speech-dispatcher \
  swww-git \
  tesseract \
  tesseract-data-eng \
  udiskie \
  upscayl-ncnn \
  waybar \
  waypaper \
  xdg-terminal-exec

# TODO: unbox things and setup services
