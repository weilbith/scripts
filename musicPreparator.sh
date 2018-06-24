#!/bin/bash
#
# Name:
#   musicPreparator
#
# SYNOPSIS:
#   musicPreparator [-s] [source-path] [-d] [destination-path] [--skip]
#
# Arguments:
#   -s [--source]       Path to the directory/file as source to convert.
#                       In case it is a directory, from there a search starts recursively for music files.
#                       All found files will be added to the track list and processed by this.
#
#   -d [--destination]  Path to the directory where to build up (or continue to integrate) the new structure.
#                       All converted files will be placed here.
#   
#   --skip              Ignore a possible remain track list and start from the bottom up.
#
#
# Description:
#   A simple tool to convert music files and create a directory structure, based on the tracks information.
#   This script is focused on using MP3. Means it convert every given source music file into MP3 if possible.
#   To convert the track and extract the tag information, it use _ffmpeg_ and _ffprobe_.
#   The resulting directory structure at the destination place has the artist as first level, followed by the album.
#   This looks like this structure:
#       - destination
#           |- artist
#           |   |- album
#           |   |   | - artist-title.mp3
#           |   |   L - ...
#           |   |
#           |   |- album2
#           |   |   ...
#           |    ...
#           |- ...
#
#   The script is resistent for fails and interruptions.
#   Therefore it creates a list of all music files in the source directory and store it into a temporally file.
#   This file is placed into the current working directory and is only purged if the script ends successfully.
#   Missing music tag informations are replaced by default values, so at least the conversion was successful.
#   Local failures, like conversion problems, lead to skip the active selected music file.
#


# Create an array by the argument string.
IFS=' ' read -r -a ARG_VEC <<< "$@"

# Adjustable configuration values.
SRC=$(pwd) # The source directory where to start searching for music files.
DST_DIR=$(pwd) # The destination directory where to place the converted music files. 

# Fixed configuration values.
TRACK_LIST_FILE="./tracklist.txt" # List where to store all music file paths, which is persistent over multiple runs (if any failed).
TMP_TRACK_FILE="$(pwd)/musicPreparator_track.mp3" # Temporally store the music file here to process it.
FFMPEG_LOG="$(pwd)/ffmpeg.log" # Log file for ffmpeg to do not polate the scripts autput.
SKIP_TRACK_LIST=false # Also if a track file exists, ignore this and create a new one.

# MP3 tags of the last parsed music file (intialized empty).
TITLE=""
ARTIST=""
ALBUM=""


# Function to create a list of all tracks in a file.
# Reuse an already existing list, if such file could been found.
# The reuse can be skipped, if the associated argument flag has been set.
# This is the usecase if the script has stopped in an earlier run.
#
function createTrackList {
  # Check if a track list file has remain from an earlier run.
  if [[ -e "$TRACK_LIST_FILE" ]] && [[ $SKIP_TRACK_LIST = 'false' ]] ; then
    echo "Reuse last track list file."

  # Create a new track list.
  else 

    # Remove an old track list file in case it should been skipped.
    rm -f "$TRACK_LIST_FILE"

    # Check if given source is a folder.
    if [[ -d "$SRC" ]] ; then
      echo "Search for track files in the source directory..."
      # Insert a line per file that has been found.
      while IFS= read -d $'\0' -r track
      do
        # Get the absolute path of the track.
        local absolutePath=$(readlink -f "$track")

        # Write the path to the track list file.
        echo "$absolutePath" >> $TRACK_LIST_FILE

      done < <(find "$SRC" -type f -print0)
    
    else
      echo "Working on a single source file."
      # Write absolute path into the track list file.
      local absolutePath=$(readlink -f "$SRC")
      echo "$absolutePath" >> $TRACK_LIST_FILE

    fi
  fi
}


# Convert audio files to MP3.
# The converted file will be stored into a temporally file, which is used for further processing.
# So far only '.m4a' is supported to be converted.
# Music files which are already in MP3 format are just copied.
#
# Arguments:
#   $1 - path to the music file, which sould be converted
#
function convertTrack {
  # Log current file to convert.
  echo -e "------------------------\n\n $1" >> $FFMPEG_LOG

  # Delete the old temporally music file.
  rm -f "$TMP_TRACK_FILE"

  # Extract the file extension.
  ext=${1##*.}

  # Differ between the different file types.
  case "$ext" in
    mp3)
      cp -f "$1" "$TMP_TRACK_FILE"
      ;;

    m4a)
      ffmpeg -i "$1" -acodec libmp3lame -ab 192k "$TMP_TRACK_FILE" >> $FFMPEG_LOG 2>&1
      ;;

    *)
      echo Unsupported music file type: $1
      ;;

  esac
}


# Get the mp3 tags of a file.
# The tags are stored globally and can be reused all following instructions.
# Procedure is working on the temporally stored music file.
# If any necessary tag could not been found, it is set to the default value.
#
function extractTags {
  # Reset the tags.
  ARTIST=""
  ALBUM=""
  TITLE=""

  # Get a full analysis of the track (including the tags).
  local tags=$(ffprobe "$TMP_TRACK_FILE" 2>&1)

  # Extract the different tags.
  ARTIST=$(echo "$tags" | sed -E -n 's/^ *artist *: (.*)/\1/p')
  ALBUM=$(echo "$tags" | sed -E -n 's/^ *album *: (.*)/\1/p')
  TITLE=$(echo "$tags" | sed -E -n 's/^ *title *: (.*)/\1/p')

  echo "Artist: $ARTIST; Album: $ALBUM; Title: $TITLE"
  # Set missing tags to default and show the user.
  [[ -z "$ARTIST" ]] && ARTIST="ARTIST" && echo "Could not found MP3 tag for the artist. Set to default."
  [[ -z "$ALBUM" ]] && ALBUM="ALBUM" && echo "Could not found MP3 tag for the album. Set to default."
  [[ -z "$TITLE" ]] && TITLE="TITLE" && echo "Could not found MP3 tag for the title. Set to default."
}


# Convert tags to a standard string format for naming files.
# This includes to remove spaces, use camel case and delete some special characters.
#
# Arguments:
#   $1 - original tag
#
# Return:
#   converted tag
#
function convertTagString {
  local convertedTag=""

  # Iterate over all words in the original tag.
  for word in $1 ; do
    # Remove the following characters: ' ? !
    word=$(echo "$word" | sed "s/['|?|!\]//g") 

    # Convert to camel case and add word to the tag without a space.
    convertedTag="${convertedTag}${word^}" 
  done

  # Return the convertede tag.
  echo $convertedTag
}


# Main function which process each music file in the track list.
# It convert the music file to MP3, extract its tags and move it into the defined library directory structure.
# This function should not contain much logic by itself.
# Should been it should stay lean and export subtasks to other functions.
#
function processTracks {
  while IFS='' read -r track || [[ -n "$track" ]]; do
    # Convert the track to mp3 format.
    echo "Track: $track"
    output=$(convertTrack "$track")

    # Check if conversion was successful (temporally file does not exist)
    if [[ ! -e $TMP_TRACK_FILE ]] ; then
      echo "Conversion failed! Skip this track."
      continue
    fi

    # Extract MP3 tags.
    extractTags

    # Convert tags to use them for the folder and file name.
    artist=$(convertTagString "$ARTIST")
    album=$(convertTagString "$ALBUM")
    title=$(convertTagString "$TITLE")

    # Define the new folder(structure) and file name.
    folder="${DST_DIR}/${artist}/${album}"
    filename="${artist}-${title}.mp3"
    filepath="${folder}/${filename}"

    # Check if the file already exist and adjust if necessary (in case multiple times the title tag is missing for the same artist and album).
    [[ -e $filepah ]] && filepath="${filepath}_`date +%s`"

    # Create the (new) folder and move the temporally music file into it.
    mkdir -p "$folder"
    mv "$TMP_TRACK_FILE" "$filepath"

  done < "$TRACK_LIST_FILE"
}


# Function to extract a path value from the argument list.
# Necessary, cause paths can contain spaces, which cause problems on parsing the arguments.
# Build up all segments in the argument list, which are part of a path.
# Starts by the given index and return also the end index, where the path stops.
#
# Arguments:
#   $1 - index in argument list where start to build
#
# Return:
#   index:path
#
function getPathArgumentValue {
  local index=$1
  local pathValue
  local finish=false

  while ! $finish ; do
    # Expand the path value by the next (first) segment.
    pathValue="$pathValue ${ARG_VEC[$index]}"

    # Get the last characters, cause spaces in a path are marked by a backslash.
    local lastChar=${pathValue:$((${#pathValue}-1))}

    # Check if this was the last path segment or jump to the next segment.
    [[ ! "$lastChar" = '\' ]] && finish=true || index=$(($index+1))
  done 

  # Remove the backslashes, cause they lead to problems when further programs parse this as a path.
  pathValue=$(echo "$pathValue" | sed 's/\\//g')

  # Return the current index and the path (mark that last one starts with a space).
  echo "$index:${pathValue:1}"
}


# Parse the arguments, given to the script by the caller.
# Not defined configuration values stay with their default values.
# A not known argument leads to an exit with status code 1.
#
# Arguments:
#   $1 - all arguments by the caller
#
function parseArguments {
  for (( i=0; i<${#ARG_VEC[@]}; i++ ))
  do
    arg="${ARG_VEC[i]}"
   
    # The source folder.
    if [[ $arg == --source ]] || [[ $arg == -s ]] ; then
      local output=$(getPathArgumentValue $i+1)
      SRC="${output#*:}" # Get the path argument.
      i=${output%:*} # Update the index depending on where the path has been ended.

    # The destination folder.
    elif [[ $arg == --destination ]] || [[ $arg == -d ]] ; then
      local output=$(getPathArgumentValue $i+1)
      DST_DIR="${output#*:}" # Get the path argument.
      i=${output%:*} # Update the index depending on where the path has been ended.

    # The flag to skip an existing track list file.
    elif [[ $arg == --skip ]] ; then
      SKIP_TRACK_LIST=true
    
    # A not known argument.
    else 
      echo Unkown argument: $arg
      exit 1
    fi
  done
}
  

# Preparation
rm -f "$FFMPEG_LOG" # Remain after each script call, if it hasn't be removed by the user already.

# Getting started
parseArguments
createTrackList
processTracks

# Tidy up
#rm -f "$TRACK_LIST_FILE" # Clear the track list after all entries have been handled.
rm -f "$TMP_TRACK_FILE" # Remove the temporally track file in case something has went wrong.
