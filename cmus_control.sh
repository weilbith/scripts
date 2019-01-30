#!/bin/bash
#
# NAME
#   CMus remote controller
#
# SYNOPSIS
#   cmus_control.sh <command>
#
# DESCRIPTION
#   Script to simplify the remote control of the CMus music player
#   in combination with an i3 mode for key mapping.
#
# COMMANDS
#   help      Print out this user information how to use.
#
#   toggle_play     Switch between the status playing and pausing,
#                   depending on the current state.
#
#   toggle_shuffle  Toggle the shuffle mode depending on the current state. 
#
#   next            Play the next title in the track-list.
#                   This switches to status playing if being paused.
#
#   previous        Play the previous title in the track-list.
#                   This switches to status playing if being paused.
#


# Configuration
TOOL_REMOTE="cmus-remote"
TOOL_NOTIFY="notify-send"

NOTIFICATION_HEADER="CMus Remote Control"

COMMAND_HELP="help"
COMMAND_TOGGLE_PLAY="toggle_play"
COMMAND_TOGGLE_SHUFFLE="toggle_shuffle"
COMMAND_PREVIOUS="previous"
COMMAND_NEXT="next"


# Functions

# Notify some information to the user.
# Try to use a notification tool.
# Reports error of tool is not accessible and use stdout then.
#
# Arguments:
#   $1 - notification message
#
function notify {
  # Notify if possible.
  if [[ -n "$(command -v "$TOOL_NOTIFY")" ]]; then
    "$TOOL_NOTIFY" "$NOTIFICATION_HEADER" "$1"
  else
    (>&2 echo "Not able to send notification by '$TOOL_NOTIFY'!")
    echo "Notification: $1"
  fi 
}


# Report an error and exit the script.
# The errors message get printed to stderr and notified to the user.
# Last is useful, since this script is meant to be used outside of a console,
# therefore errors would not reach the user directly.
#
# Arguments:
#   $1 - error message
#
function exitError {
  notify "$1"
  (>&2 echo "$1")
  exit 1
}


# Make some test to verify the environments fits.
# Fails will be notified and lead to an exit with error.
# This includes to check if the remote tool is present and
# if a CMus instance is running.
#
function sanityChecks {
  if [[ -z "$(command -v "$TOOL_REMOTE")" ]]; then
    exitError "Can not find remote tool '$TOOL_REMOTE'!"

  elif [[ -z "$(pgrep cmus)" ]]; then
    exitError "No CMus instance is running!"
  fi
}


# Print the header of this script as help.
# The header ends with the first empty line.
#
function help {
  local file="${BASH_SOURCE[0]}"
  sed -e '/^$/,$d; s/^#//; s/^\!\/bin\/bash//' "$file"
}


# Execute the provided command.
# Works in combination with the remote tool to handle the command.
# Command can be based on the current state, which has to be queried.
# Unknown command are reported.
#
# Arguments:
#   $1 - command
#
function executeCommand {
  case "$1" in
    "$COMMAND_HELP")
      help;;

    "$COMMAND_TOGGLE_PLAY")
      local status
      status=$("$TOOL_REMOTE" -C status | grep "status")

      if echo "$status" | grep -q "playing"; then
        "$TOOL_REMOTE" --pause

      else
        "$TOOL_REMOTE" --play
      fi
      ;;

    "$COMMAND_TOGGLE_SHUFFLE")
      "$TOOL_REMOTE" --shuffle;;

    "$COMMAND_PREVIOUS")
      "$TOOL_REMOTE" --prev;;

    "$COMMAND_NEXT")
      "$TOOL_REMOTE" --next;;

    *)
      exitError "Unknown command '$1'!";;
  esac
}


# Getting started.
set -e
set -o pipefail

sanityChecks
executeCommand "$1"
