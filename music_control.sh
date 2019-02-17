#!/bin/bash
#
# NAME
#   Music remote controller
#
# SYNOPSIS
#   music_control.sh [OPTION...] COMMAND
#
# DESCRIPTION
#   Tool to simplify the remote control of different music PLAYERS.
#   Either the caller can specify which player should be controlled or it will
#   be automatically tried to detected.
#   Powerful in usage with system wide key mappings like with i3.
#
# OPTIONS
#   -p, --player    Specify the PLAYER to control.
#                   If unset it will be tried to detected.
#
# COMMANDS
#   help      Print out this user information how to use.
#
#   toggle_play     Switch between the status playing and pausing,
#                   depending on the current state.
#
#   toggle_random   Toggle the random play mode for the current play-list.
#
#   next            Play the next title in the track-list.
#                   This switches to status playing if being paused.
#
#   previous        Play the previous title in the track-list.
#                   This switches to status playing if being paused.
#
# PLAYER
#   mpd  - music player daemon
#   cmus - C* music player
#


# Notification
NOTIFICATION_TOOL="notify-send"
NOTIFICATION_HEADER="CMus Remote Control"

# Command
COMMAND_SELECTED=""
COMMAND_HELP="help"
COMMAND_TOGGLE_PLAY="toggle_play"
COMMAND_TOGGLE_RANDOM="toggle_random"
COMMAND_STOP="stop"
COMMAND_PREVIOUS="previous"
COMMAND_NEXT="next"
COMMAND_LIST=(
  "$COMMAND_HELP"
  "$COMMAND_TOGGLE_PLAY"
  "$COMMAND_TOGGLE_RANDOM"
  "$COMMAND_STOP"
  "$COMMAND_PREVIOUS"
  "$COMMAND_NEXT"
)

# Player
PLAYER_CMUS_NAME="cmus"
PLAYER_CMUS_TOOL="cmus-remote"
declare -A PLAYER_CMUS_COMMANDS=(
  [$COMMAND_TOGGLE_PLAY]="--pause"
  [$COMMAND_TOGGLE_RANDOM]="--shuffle"
  [$COMMAND_STOP]="--stop"
  [$COMMAND_PREVIOUS]="--prev"
  [$COMMAND_NEXT]="--next"

)

PLAYER_MPD_NAME="mpd"
PLAYER_MPD_TOOL="mpc"
declare -A PLAYER_MPD_COMMANDS=(
  [$COMMAND_TOGGLE_PLAY]="toggle"
  [$COMMAND_TOGGLE_RANDOM]="random"
  [$COMMAND_STOP]="stop"
  [$COMMAND_PREVIOUS]="prev"
  [$COMMAND_NEXT]="next"
)

PLAYER_ACTIVE=""
PLAYER_LIST=(
  "$PLAYER_CMUS_NAME"
  "$PLAYER_MPD_NAME"
) # Order defines priority (put mpd at end cause it should run as daemon as kinda fallback).

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
  if [[ -n "$(command -v "$NOTIFICATION_TOOL")" ]]; then
    "$NOTIFICATION_TOOL" "$NOTIFICATION_HEADER" "$1"
  else
    (>&2 echo "Not able to send notification by '$NOTIFICATION_TOOL'!")
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
function exitError() {
  notify "$1"
  (>&2 echo "$1")
  exit 1
}


function parseArguments() {
  local arg_vector
  IFS=' ' read -r -a arg_vector <<< "$@"

  for (( i=0; i<${#arg_vector[@]}; i++ )) ; do
    arg="${arg_vector[i]}"
    nextIndex=$((i + 1))

    # The player
    if [[ $arg == -p ]] || [[ $arg == --player ]]; then
      local player="${arg_vector[$nextIndex]}"

      # Find and set the defined player.
      for entry in "${PLAYER_LIST[@]}"; do
        [[ "$player" == "$entry" ]] && PLAYER_ACTIVE="$player"
      done

      # Check if it was a valid player.
      if [[ -z "$PLAYER_ACTIVE" ]]; then
        help
        exitError "Unknown player: '$player'!"
      fi

      i=$nextIndex # Jump other the player name index.

    
    # Argument without prefix -> check for command
    else
      # Find and set the defined command.
      for command in "${COMMAND_LIST[@]}"; do
        [[ "$arg" == "$command" ]] && COMMAND_SELECTED="$arg"
      done

      # Check if it was a valid command.
      if [[ -z "$COMMAND_SELECTED" ]]; then
        help
        exitError "Unknown argument '$arg'!"
      fi
    fi
  done

  if [[ -z "$COMMAND_SELECTED" ]]; then
    help
    exitError "Make sure to specify at least a command to execute!"
  fi
}


function detectPlayer_cmus() {
  [[ -z "$(command -v "$PLAYER_CMUS_TOOL")" ]] && return
  [[ -z "$(pgrep cmus)" ]] && return
  "$PLAYER_CMUS_TOOL" -Q | grep 'stopped' &> /dev/null && return
  echo "$PLAYER_CMUS_NAME"
}


function detectPlayer_mpd() {
  [[ -z "$(command -v "$PLAYER_MPD_TOOL")" ]] && return
  "$PLAYER_MPD_TOOL" &> /dev/null || return
  "$PLAYER_MPD_TOOL" status | grep 'playing\|paused' &> /dev/null || return
  echo "$PLAYER_MPD_NAME"
}


function detectPlayer() {
  [[ -n "$PLAYER_ACTIVE" ]] && return

  for player in "${PLAYER_LIST[@]}"; do
    eval PLAYER_ACTIVE="$("detectPlayer_$player")"
    [[ -n "$PLAYER_ACTIVE" ]] && return
  done

  if [[ -z "$PLAYER_ACTIVE" ]]; then
    help
    exitError "No player explicit defined and none could been automatically detected."
  fi
}


# Print the header of this script as help.
# The header ends with the first empty line.
#
function help() {
  local file="${BASH_SOURCE[0]}"
  sed -e '/^$/,$d; s/^#//; s/^\!\/bin\/bash//' "$file"
}


function executeCommand() {
  [[ "$COMMAND_SELECTED" == "$COMMAND_HELP" ]] && help && exit 0
  eval "\$PLAYER_${PLAYER_ACTIVE^^}_TOOL \${PLAYER_${PLAYER_ACTIVE^^}_COMMANDS[$COMMAND_SELECTED]}"
}


# Getting started.
set -e
set -o pipefail

parseArguments "$@"
detectPlayer
executeCommand
