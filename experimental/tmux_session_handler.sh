#!/bin/bash

SESSION_NAMES=(Berlin Amsterdam London Paris Rom Florence Edinburgh Glasgow Lindenhof NewYork)
MAX_WINDOWS_PER_SESSION=9 # More windows are not well controllable by default key bindings.
SESSION_VIEW_INFIX="#"
# TMUX="tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf"


# Simple checks to make sure everything needed is available.
#
function sanity_checks() {
  if ! command -v tmux > /dev/null && [[ -n "$(command -v tmux)" ]]; then
    echo "TMux is not available!"
    exit 1
  fi

  if ! command -v awk > /dev/null; then
    echo "Awk is not available!"
    exit 1
  fi
}


# Get the list of all TMux sessions.
#
# Returns:
#   session list
#
function get_session_list() {
  tmux list-sessions
}


# Get the number of open windows for a specific session.
#
# Arguments:
#   $1 - name of the session to check for
#
# Returns:
#   count of windows in this session
#
function get_window_count() {
  windows="$(tmux list-windows -t "$1")"
  window_count=0

  while IFS=$'\n' read -r window || [ -n "$window" ]; do
    window_count=$((window_count + 1))
  done <<< "$windows"

  echo $window_count
}


function check_session_name_used() {
  get_session_list | grep -q "^$1"
}


# Get a name of the predefined list which is not used for any session so far.
# In case that all sessions names are in usage, this leads to an empty string.
#
# Returns:
#   free session name
#
function get_free_session_name() {
  unused_session_name=""

  for session_name in "${SESSION_NAMES[@]}"; do
    if ! check_session_name_used "$session_name"; then
      unused_session_name="$session_name"
      break
    fi
  done

  echo "$unused_session_name"
}


# Retrieve the name of the session to attach or create.
# Sorts all active sessions by their time of creation and check in this order
# which sessions has not reached the maximum number of windows.
# In case all active sessions are full, the name for a new to create sessions is
# determined. This can be an empty name, which forces TMux to use the next
# default name.
#
# Returns:
#   session name to use
#
function get_to_use_session_name() {
  sessions_sorted="$(get_session_list | sort -s -k 6M -k 7 -k 8,1 -k 8,2 -k 8,3 -k 8,4)" 
  to_use_session_name=""
  
  while IFS=$'\n' read -r session || [ -n "$session" ]; do
    session_name="$(echo "$session" | awk -F '#' '{print $1}')"
    window_count="$(get_window_count "$session_name")"

    if [[ $window_count -lt $MAX_WINDOWS_PER_SESSION ]]; then
      to_use_session_name="$(echo "$session_name" | awk -F ':' '{print $1}')"
      break
    fi
  done <<< "$sessions_sorted"
  
  [[ -z "$to_use_session_name" ]] && to_use_session_name="$(get_free_session_name)"
  
  echo "$to_use_session_name"
}


function get_session_view_id() {
  id_list="$(get_session_list | grep "$1" | awk -F ':' '{print $1}' | awk -F "$SESSION_VIEW_INFIX" '{print $2}' | sed -r '/^$/d' | sort -n)"
  last_id="${id_list##*$'\n'}"
  next_id=$((last_id + 1))

  echo "$next_id"
}


# Start TMux and attach to the given session, if such already exist with this
# name and open a new window there. Else a new session with this name will be
# created. As last case when no name has been defined, the default TMux create
# session command is used.
#
function start_tmux() {
  if [[ -n "$1" ]] ; then
    echo "Name: $1"
    if check_session_name_used "$1"; then
      echo "Used"
      view_id="$(get_session_view_id "$1")"
      session="$1$SESSION_VIEW_INFIX$view_id"
      echo "Use Name: $session"
      # tmux new-session -s "$session" -t "$1" \; new-window
      tmux new-session -s "$session" -t "$1" \; new-window

    else
      session="$1${SESSION_VIEW_INFIX}1"
      echo "new $session"
      # $TMUX new-session -s "$session"
      tmux new-session -s "$session"
    fi

  else
    echo "complete new"
    # $TMUX new
  fi
}


sanity_checks
session_name="$(get_to_use_session_name)"
start_tmux "$session_name"
