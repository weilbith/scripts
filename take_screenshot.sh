#!/bin/bash

# Create an array by the argument string.
IFS=' ' read -r -a ARG_VEC <<<"$@"

# The tool to do screenshots.
TOOL=scrot

# Image file properties.
IMG_DIR=~/Bilder/Screenshots      # Default folder to save the image. Can be changed by argument.
IMG_NAME="screenshot_$(date +%s)" # Default file name to save the image. Can be changed by argument.
IMG_TYPE=png                      # Default type. Can be changed by argument.

# Execution properties.
TOOL_ARGS="$TOOL"

# Make sure that _scrot_ is installed.
# Print an exception if not so end exit with status code 1.
#
function checkInstallation() {
  if ! command -v "$TOOL" >/dev/null; then
    echo "The tool to take the screenshot ($TOOL) is not installed!"
    exit 1
  fi
}

# Parse the arguments, given to the script by the caller.
# Overwrite the default property values of the image, if they are defined.
# Also add further execution arguments to the tool.
#
function parseArguments() {
  for ((i = 0; i < ${#ARG_VEC[@]}; i++)); do
    arg="${ARG_VEC[i]}"

    # Check if a folder to save image has been defined.
    if [ "$arg" == --path ] || [ "$arg" == -p ]; then
      IMG_DIR="${ARG_VEC[i + 1]}" # Parse next argument as the folder path.
      i=$((i + 1))                # Jump over the next argument.

    # Check if a file name to save image has been defined.
    elif [ "$arg" == --name ] || [ "$arg" == -n ]; then
      IMG_NAME="${ARG_VEC[i + 1]}" # Parse next argument as the file name.
      i=$((i + 1))                 # Jump over the next argument.

    # Check if the image file type has been defined.
    elif [ "$arg" == --type ] || [ "$arg" == -t ]; then
      IMG_TYPE="${ARG_VEC[i + 1]}" # Parse next argument as the image type.
      i=$((i + 1))                 # Jump over the next argument.

    # Check if a further argument to the tool is given.
    elif [ "$arg" == --args ] || [ "$arg" == -a ]; then
      TOOL_ARGS="$TOOL_ARGS ${ARG_VEC[i + 1]}" # Add argument to the list.
      i=$((i + 1))                             # Jump over the next argument.
    fi
  done
}

# Check if the defined image type is supported.
# Print exception message if not so and exit with status code 1.
#
function checkImageType() {
  case $IMG_TYPE in
  # Do nothing for all supported types.
  png) ;;
  jpg) ;;
  jpeg) ;;

  # Here comes the case if the type is not supported.
  *)
    echo "The defined image type .$IMG_TYPE is not supported!"
    exit 1
    ;;
  esac
}

# Final execution to take the screenshot and save the image.
#
function execute() {
  tmp_file=$(mktemp)
  img_dir="$IMG_DIR"

  kitty --name floating -o initial_window_width=400 -o initial_window_height=100 -o remember_window_size=no \
    sh -c "read -p 'Change default location (default $IMG_DIR) [yN]? ' -n1 answer && echo \$answer > $tmp_file"

  answer=$(cat "$tmp_file")

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    kitty --name floating -o initial_window_width=1500 -o initial_window_height=800 -o remember_window_size=no \
      ranger --choosedir "$tmp_file" --show-only-dirs "$IMG_DIR"

    img_dir=$(cat "$tmp_file")
  fi

  rm "$tmp_file"
  path="$img_dir/$IMG_NAME.$IMG_TYPE"
  $TOOL_ARGS "$path"
  command -v notify-send >/dev/null && notify-send "New Screenshot" "Saved at $path"
}

# Getting started.
checkInstallation
parseArguments
checkImageType
execute
