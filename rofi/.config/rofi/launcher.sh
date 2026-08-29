#!/usr/bin/env bash

set -uo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${ROFI_CONFIG_DIR:-$script_dir}"
show_mode="${1:-combi}"

if [[ "$show_mode" == "--show" ]]; then
    show_mode="${2:-combi}"
fi

case "$show_mode" in
    combi|drun|window|run|media|timers|sound|session) ;;
    *) show_mode="combi" ;;
esac

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

rasi_escape() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\n'/ }"
    printf '%s' "$value"
}

player_summary="No active player"
if command -v playerctl >/dev/null 2>&1; then
    player_summary="$(playerctl metadata --format '{{artist}} — {{title}}' 2>/dev/null || true)"
    [[ -n "$player_summary" ]] || player_summary="No active player"
fi

volume_summary="Volume unavailable"
if command -v wpctl >/dev/null 2>&1; then
    volume_summary="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
    volume_summary="${volume_summary/Volume: /}"
    if [[ "$volume_summary" =~ ^([0-9]+\.?[0-9]*) ]]; then
        volume_summary="$(awk -v volume="${BASH_REMATCH[1]}" 'BEGIN { printf "%d%%", volume * 100 }')${volume_summary#${BASH_REMATCH[1]}}"
    fi
elif command -v pactl >/dev/null 2>&1; then
    volume_summary="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk 'match($0, /[0-9]+%/) { print substr($0, RSTART, RLENGTH); exit }')"
    [[ -n "$volume_summary" ]] || volume_summary="Volume unavailable"
    if pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -q 'yes'; then
        volume_summary="$volume_summary · muted"
    fi
fi

theme_override="textbox-player-track { content: \"$(rasi_escape "$player_summary")\"; } textbox-volume { content: \"  $(rasi_escape "$volume_summary")\"; }"
search_modes="drun,window,run,media,timers,sound,session"
mode_list="combi,drun,window,run,media:$config_dir/scripts/media,timers:$config_dir/scripts/bide,sound:$config_dir/scripts/sound,session:$config_dir/scripts/session"

if "$rofi_bin" -help 2>&1 | grep -q -- '-modes'; then
    mode_flag="-modes"
    combi_flag="-combi-modes"
else
    mode_flag="-modi"
    combi_flag="-combi-modi"
fi

exec "$rofi_bin" \
    -show "$show_mode" \
    "$mode_flag" "$mode_list" \
    "$combi_flag" "$search_modes" \
    -theme "$config_dir/cockpit.rasi" \
    -theme-str "$theme_override" \
    -replace
