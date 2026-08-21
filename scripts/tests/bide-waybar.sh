#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
config="$repo_dir/waybar/.config/waybar/config"

jq empty "$config"
jq -e '."custom/bide"."on-click" | contains("--show timers")' "$config" >/dev/null
jq -e '."custom/bide"."on-click-middle" == "bide waybar toggle"' "$config" >/dev/null
jq -e '."custom/bide"."on-click-right" | contains("BIDE_ROFI_DISPLAYED=1")' "$config" >/dev/null
grep -q '#custom-bide.paused' "$repo_dir/waybar/.config/waybar/style.css"
printf 'Bide Waybar adapter fixtures passed\n'
