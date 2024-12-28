SHMUX_DIR="$(dirname "$(readlink -f "$0")")"
. "$SHMUX_DIR/../util/functions.sh"

# Set up your project with a root dir, and name
project_root ~/Documents/Repos/mpro-platform
session_name "odyssey"

# first, create your session
new_session

# then, layout your session
rename_window "code"
run_command "nvim"

new_window "servers"
run_command "cd app/odyssey/client"
rename_pane "client"
run_command "dotnet run --watch"
split_horizontal 66%

rename_pane "identityserver"
run_command "cd app/odyssey/identityserver"
run_command "dotnet run --watch"
split_horizontal 50%

rename_pane "api"
run_command "cd app/odyssey/api"
run_command "dotnet run --watch"

# at the end, select the window you want first
select_window "1"

# then, attach to your session!
attach_to_session
