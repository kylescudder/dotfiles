# schmerdr layout template.
#
# `schmerdr new <name>` copies this file to layouts/<name>.sh for you to edit.
# `schmerdr load <name> [args...]` sources it; args arrive here as $1, $2, ...
#
# The DSL (project_root, new_workspace, new_tab, split_*, run_command, ready_when,
# wait_ready, start_agent, prompt_agent, new_worktree, focus_tab, attach) is in scope.
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
WEB_READY="localhost:"

new_tab "Watch"
run_command "npm ci"
run_command "npm run watch"

# --- tab: Git -------------------------------
new_tab "Git"
run_command "lazygit"

# --- tab: nvim -------------------------------
new_tab "nvim"
run_command "nvim"

# Everything is laid out — go back to pane 1 (Agents, left of the browser) and
# start Claude there last, into the settled layout.
focus_home
start_agent claude "${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo Saturn)}"
attach
