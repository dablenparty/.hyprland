#!/usr/bin/env bash

# e: fail script if any command fails
# x: print every command before it's run
set -ex

# TODO: args with getopts or GNU getopt
# -n: pass --noconfirm to paru
# -r: update rustup stable

# NOTE: rustup self-updates on any invocation of the "update" subcommand
# If that ever changes, uncomment the line below
# rustup self update
rustup toolchain update nightly

# I don't like using sudoloop, but this script is an exception
paru --sudoloop
