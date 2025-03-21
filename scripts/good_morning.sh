#!/usr/bin/env bash

set -e

paru
rustup self update
rustup toolchain update nightly
