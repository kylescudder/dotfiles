#!/usr/bin/env bash

set -uo pipefail

unit_separator=$'\x1f'

mode_option() {
    printf '\0%s%s%s\n' "$1" "$unit_separator" "$2"
}

mode_header() {
    local prompt="$1"
    local message="$2"
    mode_option "prompt" "$prompt"
    mode_option "message" "$message"
    mode_option "markup-rows" "true"
    mode_option "no-custom" "true"
}

mode_row() {
    local label="$1"
    local subtitle="$2"
    local icon="$3"
    local info="$4"
    local state="${5:-normal}"
    local display="<span weight='medium'>${label}</span>  <span size='small' foreground='#7f849c'>·  ${subtitle}</span>"

    printf '%s\0display\x1f%s\x1ficon\x1f%s\x1finfo\x1f%s' \
        "$label" "$display" "$icon" "$info"

    case "$state" in
        urgent) printf '%surgent%strue' "$unit_separator" "$unit_separator" ;;
        active) printf '%sactive%strue' "$unit_separator" "$unit_separator" ;;
        disabled) printf '%snonselectable%strue' "$unit_separator" "$unit_separator" ;;
    esac
    printf '\n'
}

rasi_escape() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\n'/ }"
    printf '%s' "$value"
}

pango_escape() {
    local value="$1"
    value="${value//&/\&amp;}"
    value="${value//</\&lt;}"
    value="${value//>/\&gt;}"
    printf '%s' "$value"
}

launch_background() {
    if command -v setsid >/dev/null 2>&1; then
        setsid -f "$@" >/dev/null 2>&1
    else
        "$@" >/dev/null 2>&1 </dev/null &
    fi
}
