SHMUX_DIR="$(dirname "$(readlink -f "$0")")"
. "$SHMUX_DIR/../util/functions.sh"

# Set up your project with a root dir, and name
project_root ~/Documents/Repos/the-date-pot
session_name "the-date-pot"

# first, create your session
new_session

# then, layout your session
rename_window "code"
run_command "nvim"

new_window "servers"
rename_pane "bun dev"
run_command "bun dev"

split_horizontal 66%
rename_pane "drizzle"
run_command "bunx drizzle-kit studio"

split_horizontal 50%
rename_pane "prettier"
run_command "~/Documents/Repos/scripts/stashpullpop ./"
run_command "bun format"
# 
# # at the end, select the window you want first
select_window "0"
# 
# # then, attach to your session!
attach_to_session
