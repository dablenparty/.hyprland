#!/usr/bin/env sh

exec /usr/bin/env ENABLE_LSFG=1 LSFG_MULTIPLIER="${LSFG_MULTIPLIER:-4}" "$@"
