# schmerdr layout template.
#
# `schmerdr new <name>` copies this file to layouts/<name>.sh for you to edit.
# `schmerdr load <name> [args...]` sources it; args arrive here as $1, $2, ...
#
# The DSL (project_root, new_workspace, new_tab, split_*, run_command,
# ready_when, wait_ready, start_agent, new_worktree, focus_tab, attach) is in scope.
#
# Example: `schmerdr load Odyssey Dev` -> dotnet runs with --launch-profile Dev
#          `schmerdr load Odyssey`     -> falls back to --launch-profile Development

use_current_workspace

# --- tab: Agents ------------------------------------------------------------
rename_tab "Agents"
start_agent claude "${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo Odyssey)}"

# --- tab: Watch ---------------------------------------------------------------
# Services boot one at a time: each pane holds until the previous one logs READY,
# so their builds don't fight over shared obj/bin in libs/odyssey + libs/platform.
# READY is the "up" line to match — tune it if your apps log something else (the
# func host may prefer e.g. "Worker process started and initialized").
READY="Now listening on"

new_tab "Watch"
# API is a .NET isolated Functions app — it can't `dotnet watch` (the worker needs
# the Functions host for its gRPC channel). Restart `func host start` on change via
# watchexec; profile -> AZURE_FUNCTIONS_ENVIRONMENT is resolved from launchSettings.
run_command "AZURE_FUNCTIONS_ENVIRONMENT=\$(jq -r --arg p \"${2:-Development}\" '.profiles[\$p].environmentVariables.AZURE_FUNCTIONS_ENVIRONMENT // \"docker\"' apps/odyssey/api/Properties/launchSettings.json) watchexec --restart --debounce 500ms -e cs,csproj,json -w apps/odyssey/api -w libs/odyssey -w libs/platform -- 'cd apps/odyssey/api && func host start'"
ready_when "$READY"

split_down 30%
wait_ready                    # hold until the API is up
run_command "cd apps/odyssey/identityserver"
run_command "dotnet watch --launch-profile ${2:-Development}"
ready_when "$READY"

split_down 50%
wait_ready                    # hold until the identity server is up
run_command "cd apps/odyssey/client"
run_command "dotnet watch --launch-profile ${2:-Development}"
ready_when "$READY"

# --- tab: Test -------------------------------
# Runs only once the client (last service) is up, so tests don't rebuild shared
# libs while the watchers are still compiling them.
new_tab "Test"
wait_ready
run_command "cd apps/odyssey"
run_command "dotnet test odyssey.sln --filter 'TestCategory!=E2E'"

# --- tab: Git -------------------------------
new_tab "Git"
run_command "lazygit"

# Land on the api tab and attach.
focus_tab "Agents"
attach
