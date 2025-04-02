#!/usr/bin/env bash

# e: fail script if any command fails
set -e

if [ -z "$OPTIND" ]; then
  OPTIND=1
fi

option_noconfirm=false
option_update_rustup=false

while getopts "hnr" opt; do
  case $opt in
  h)
    printf "usage: %s [-hnr]\n  -h    show this help text\n  -n    pass --noconfirm to paru\n  -r    update rustup stable+nightly\n" "$0" 1>&2
    exit 1
    ;;
  n)
    option_noconfirm=true
    ;;

  r)
    option_update_rustup=true
    ;;

  ?)
    printf "Invalid option: -%s\n" "$OPTARG" 1>&2
    exit 1
    ;;
  esac
done

# NOTE: rustup self-updates on any invocation of the "update" subcommand
# If that ever changes, uncomment the line below
# rustup self update
if [[ $option_update_rustup = true ]]; then
  rustup update
else
  rustup toolchain update nightly
fi

if [[ $option_noconfirm = true ]]; then
  paru -Syu --noconfirm --sudoloop
else
  paru -Syu --sudoloop
fi
