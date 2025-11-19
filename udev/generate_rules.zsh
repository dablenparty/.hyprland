#!/usr/bin/env zsh

setopt rematchpcre

BASE_RULE_PATH="$PWD/rules.d"
rm -rvf "$BASE_RULE_PATH"
mkdir -v "$BASE_RULE_PATH"

# NEW STEPS:
# 1. get a list of GPU's and their id
# 2. select one with fzf
# 3. prompt user for link name
# 4. save to rules.d

declare -A devices
while read -r device; do
  if [[ "$device" =~ "^(\d+:\d+\.\d).+?: (.+?) \(rev \w\d\)$" ]]; then
    echo "id=${match[1]}"
    echo "name=${match[2]}"
    # devices[name]=id
    devices[${match[2]}]=${match[1]}
  fi
done <<<"$(lspci -d ::03xx)"

selected_gpu="$(printf '%s\n' ${(@k)devices} | fzf --prompt='Select a GPU to use for Hyprland>')"
gpu_id=${devices[$selected_gpu]}
symlink_name='aq-gpu'
rule_path="$BASE_RULE_PATH/$symlink_name-dev-path.rules"
echo "selected card '$gpu_id', generating rules $rule_path"
cat >"$rule_path" <<EOF
KERNEL=="card*", \
KERNELS=="0000:$gpu_id", \
SUBSYSTEM=="drm", \
SUBSYSTEMS=="pci", \
SYMLINK+="dri/$symlink_name"
EOF

echo "done!"
