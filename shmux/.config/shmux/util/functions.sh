#! /bin/sh

# this is the DSL for our tmux plugin

project_root() {
  ROOT=$1
}

session_name() {
  SESSION_NAME=$1
}

set_current_window() {
  CURRENT_WINDOW=$1
}

set_current_pane() {
  CURRENT_PANE=$1
}

select_window() {
  tmux select-window -t "$SESSION_NAME:$1"
}

new_session() {
  dir=$(readlink --canonicalize "$ROOT")
  tmux new-session -d -s "$SESSION_NAME" -c "$ROOT"
}

new_window() {
  # Check if a window with the desired name already exists
  if ! tmux list-windows -t "$SESSION_NAME" | grep -q $1; then
    # If the window doesn't exist, create it
    tmux new-window -t "$SESSION_NAME" -c "$ROOT" -n $1
  else
    # If the window exists, switch to it
    tmux select-window -t "$SESSION_NAME:$1"
  fi
  set_current_window $1
}

split_vertical() {
  tmux split-window -t "$SESSION_NAME:$CURRENT_WINDOW.$CURRENT_PANE" -c "$ROOT" -v -l $1
  set_current_pane $(($CURRENT_PANE + 1))
}

split_horizontal() {
  tmux split-window -t "$SESSION_NAME:$CURRENT_WINDOW.$CURRENT_PANE" -c "$ROOT" -h -l $1
  set_current_pane $(($CURRENT_PANE + 1))
}

rename_window() {
  tmux rename-window -t "$SESSION_NAME:zsh" $1
}

rename_pane() {
  tmux select-pane -T $1
}

attach_to_session() {
  tmux attach-session -t "$SESSION_NAME"
}

run_command() {
  tmux send-keys -t "$SESSION_NAME:$CURRENT_WINDOW.$CURRENT_PANE" "$1" C-m
}
