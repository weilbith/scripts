#!/bin/bash

# Variables
COMMAND=wicd-curses
LOG_FILE=/tmp/wicd_stablizer.log

# Make command is available.
command -v $COMMAND>/dev/null || exit 1

# Restart command as long as it quits with an error.
while : ; do
  # Unfortunately the command is not return an exit code unequal one.
  # Therefore check the programs error output.
  $COMMAND 2> $LOG_FILE
  [[ -f $LOG_FILE ]] && output=$(cat $LOG_FILE)
  echo "Output: $output"
  [[ -z "$output" ]] && echo "done" && break
  echo "restart..."
done

# Tidy up.
echo 'Clean up'
rm -f $LOG_FILE
