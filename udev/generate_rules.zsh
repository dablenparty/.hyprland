#!/usr/bin/env zsh

BASE_RULE_PATH="$PWD/rules.d"
rm -rvf "$BASE_RULE_PATH"
mkdir -v "$BASE_RULE_PATH"

# TODO: support arbitrary gpu's with regex parsing
symlinks_to_make=("amd-igpu" "nvidia-dgpu")
for symlink_name in "${(@kv)symlinks_to_make}"; do
  rule_path="$BASE_RULE_PATH/$symlink_name-dev-path.rules"
  echo "finding card..."
  ident="${(U)symlink_name%%-*}"
  gpu_id="$(lspci -d ::03xx | grep "$ident" | cut -f1 -d' ')"
  echo "found card '$gpu_id', generating rules $rule_path"
  cat >"$rule_path" <<EOF
KERNEL=="card*", \
KERNELS=="0000:$gpu_id", \
SUBSYSTEM=="drm", \
SUBSYSTEMS=="pci", \
SYMLINK+="dri/$symlink_name"
EOF
done

echo "done!"
