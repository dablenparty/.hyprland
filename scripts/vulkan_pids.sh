#!/usr/bin/env bash

for pid in /proc/[0-9]*; do
    owner=${ stat -c %U "$pid" 2>/dev/null; }
    if [[ "$owner" == "$USER" ]]; then
        if grep -qi 'vulkan' "$pid/maps" 2>/dev/null; then
            procname=${ cat "$pid/comm" 2>/dev/null; }
            if [[ -n "$procname" ]]; then
                printf "PID %s: %s\n" "${ basename "$pid"; }" "$procname"
            fi
        fi
    fi
done
