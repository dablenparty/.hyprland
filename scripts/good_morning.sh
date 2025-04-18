#!/usr/bin/env bash

# e: fail script if any command fails
set -e

if [ -z "$OPTIND" ]; then
  OPTIND=1
fi

option_update_couchlab=false
option_noconfirm=false
option_update_rustup=false

while getopts "chnr" opt; do
  case $opt in
  c)
    option_update_couchlab=true
    ;;
  h)
    printf "usage: %s [-chnr]\n  -c    update couchlab too\n  -h    show this help text\n  -n    pass --noconfirm to paru\n  -r    update rustup stable+nightly\n" "$0" 1>&2
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

paru_cmd=""
if [[ $option_noconfirm = true ]]; then
  paru_cmd="paru -Syu --noconfirm --sudoloop"
else
  paru_cmd="paru -Syu --sudoloop"
fi

# NOTE: paru has an issue that causes it to exit with code 2 when using a custom PKGBUILD.
# To get around it, I'm just allowing it to error out and still continue the script.
# When it's fixed, I should remove this workaround.
# see: https://github.com/Morganamilo/paru/issues/1234
set +e
eval "$paru_cmd"
set -e
if [[ $option_update_couchlab = true ]]; then
  ssh -tt couchlab "$paru_cmd; systemctl reboot"
fi

echo "Don't forget to reboot!"
