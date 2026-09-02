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

if "$rofi_bin" -help 2>&1 | grep -q -- '-modes'; then
    mode_flag="-modes"
else
    mode_flag="-modi"
fi

choice="$(printf '%s\n' \
    '  Sound' \
    '󰎈  Media' \
    '  Session' \
    | "$rofi_bin" -dmenu -p 'Actions' -theme "$config_dir/cockpit.rasi" -replace)" || exit 0

case "$choice" in
    *Sound)
        exec "$rofi_bin" -show sound "$mode_flag" "sound:$config_dir/scripts/sound" -theme "$config_dir/cockpit.rasi" -replace
        ;;
    *Media)
        exec "$rofi_bin" -show media "$mode_flag" "media:$config_dir/scripts/media" -theme "$config_dir/cockpit.rasi" -replace
        ;;
    *Session)
        exec "$rofi_bin" -show session "$mode_flag" "session:$config_dir/scripts/session" -theme "$config_dir/cockpit.rasi" -replace
        ;;
esac
