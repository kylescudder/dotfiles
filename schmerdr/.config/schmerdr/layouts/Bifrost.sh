# schmerdr layout template.
#
# `schmerdr new <name>` copies this file to layouts/<name>.sh for you to edit.
# `schmerdr load <name> [args...]` sources it; args arrive here as $1, $2, ...
#
# The DSL (project_root, new_workspace, new_tab, split_*, run_command, ready_when,
# wait_ready, open_browser, start_agent, new_worktree, focus_tab, focus_home,
# attach) is in scope.
#
# Example: `schmerdr load Odyssey Dev` -> dotnet runs with --launch-profile Dev
#          `schmerdr load Odyssey`     -> falls back to --launch-profile Development

use_current_workspace

# --- tab: Agents ------------------------------------------------------------
# Pane 1 is where Claude will go (started last, below). Split the app browser in
# beside it now, before the other tabs, so the layout is settled by the time the
# agent takes over pane 1. (It'll show "connection refused" until the web dev
# server below is up — just reload it then.)
rename_tab "Agents"
open_browser "http://localhost:4200" right

# --- tab: Watch ---------------------------------------------------------------
# Boot the API first, then the web app: `gen:api:full` reads the running API's
# swagger, and gating also serialises the two `bun i` (below) so they don't write
# the same node_modules at once. Tune the match strings if your apps log something
# else ("localhost:" catches most web dev servers' startup URL; it fires only
# after `bun i` here, so the test tab's install waits for this one to finish).
API_READY="Now listening on"
WEB_READY="localhost:"

new_tab "Watch"
run_command "cd apps/bifrost/api"
run_command "dotnet watch --launch-profile ${2:-Development}"
ready_when "$API_READY"

split_down 50%
wait_ready                    # web waits for the API (gen:api:full needs it up)
run_command "cd apps/bifrost/web"
run_command "bun i"
run_command "bun run gen:api:full"
run_command "bun run start"
ready_when "$WEB_READY"

# --- tab: Test -------------------------------
new_tab "Test"
wait_ready                    # dotnet test waits for the API build to settle
run_command "cd apps/bifrost"
run_command "dotnet test"
split_down 50%
wait_ready                    # web's install/tests wait for the Watch bun i to finish
run_command "cd apps/bifrost/web"
run_command "bun i"
run_command "bun run test:ci"

# --- tab: Git -------------------------------
new_tab "Git"
run_command "lazygit"

# --- tab: nvim -------------------------------
new_tab "nvim"
run_command "nvim"

# Everything is laid out — go back to pane 1 (Agents, left of the browser) and
# start Claude there last, into the settled layout.
focus_home
start_agent claude "${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo Bifrost)}"
attach
