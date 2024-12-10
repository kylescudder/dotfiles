SHMUX_DIR="$(dirname "$(readlink -f "$0")")"
. "$SHMUX_DIR/../util/functions.sh"

# Set up your project with a root dir, and name
project_root ~/Documents/Repos/JSP
session_name "JSP"

# first, create your session
new_session

# then, layout your session
rename_window "code"
run_command "nvim"

new_window "servers"
rename_pane "dotnet run"
run_command "dotnet run --watch"
split_horizontal 66%

# at the end, select the window you want first
select_window "1"

# then, attach to your session!
attach_to_session
