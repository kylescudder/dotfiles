#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${ROFI_CONFIG_DIR:-$script_dir}"

if [[ -n "${ROFI_BIN:-}" ]] && command -v "$ROFI_BIN" >/dev/null 2>&1; then
    rofi_bin="$ROFI_BIN"
elif command -v rofi >/dev/null 2>&1; then
    rofi_bin="rofi"
elif command -v rofi-wayland >/dev/null 2>&1; then
    rofi_bin="rofi-wayland"
else
    command -v notify-send >/dev/null 2>&1 && notify-send "Rofi" "Neither rofi nor rofi-wayland is installed"
    exit 127
fi

exec "$rofi_bin" \
    -show drun \
    -modi drun \
    -theme "$config_dir/cockpit.rasi" \
    -replace
