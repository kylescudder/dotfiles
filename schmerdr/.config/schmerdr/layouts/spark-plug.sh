# schmerdr layout template.
#
# `schmerdr new <name>` copies this file to layouts/<name>.sh for you to edit.
# `schmerdr load <name> [args...]` sources it; args arrive here as $1, $2, ...
#
# The DSL (project_root, new_workspace, new_tab, split_*, run_command,
# start_agent, prompt_agent, new_worktree, focus_tab, attach) is already in scope.
#
# Args from `schmerdr load` arrive as $1, $2, ... This template uses:
#   $1 = Claude session name (differs per worktree; defaults to the branch)
#   $2 = .NET launch profile   (defaults to Development)
# Example: `schmerdr load cool-project PROJ-123 Dev`

# project_root defaults to the dir you ran `schmerdr load` from (great for
# worktrees). Uncomment to pin a fixed location instead:
# project_root ~/projects/cool-project

use_current_workspace

# --- tab: Agents ------------------------------------------------------------
rename_tab "Agents"
start_agent claude "${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo Bifrost)}"

# --- tab: Watch ---------------------------------------------------------------
new_tab "xcode"
run_command "open -na 'XCode.app' --args $('PWD')"

# --- tab: Git -------------------------------
new_tab "Git"
run_command "lazygit"

# Land on the api tab and attach.
focus_tab "Agents"
attach
