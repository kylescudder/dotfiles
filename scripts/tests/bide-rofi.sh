#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
adapter="$repo_dir/rofi/.config/rofi/scripts/bide"
temp_dir="$(mktemp -d)"
trap 'rm -rf -- "$temp_dir"' EXIT

PATH="$temp_dir:/usr/bin" /usr/bin/bash "$adapter" | grep -q 'Bide is not installed'

printf '#!/usr/bin/env bash\nprintf "New timer\\0info\\x1fnew_timer\\n"\n' >"$temp_dir/bide"
chmod +x "$temp_dir/bide"
PATH="$temp_dir:/usr/bin" /usr/bin/bash "$adapter" | grep -q 'New timer'

printf '#!/usr/bin/env bash\nprintf "invalid duration" >&2\nexit 2\n' >"$temp_dir/bide"
chmod +x "$temp_dir/bide"
PATH="$temp_dir:/usr/bin" /usr/bin/bash "$adapter" | grep -q 'invalid duration'

grep -q 'timers:.*scripts/bide' "$repo_dir/rofi/.config/rofi/launcher.sh"
printf 'Bide Rofi adapter fixtures passed\n'
