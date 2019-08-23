#!/bin/bash
#
# Start the i3locker with specific color scheme.
#
# Arguments:
#   $1 - path to wallpaper
#

# Colors
BLUE_LIGHT='#5fd7ff'
BLUE_MEDIUM='#00afd7'
BLUE_DARK='#005f87'
GREEN_LIGHT='#d7ff5f'
RED_LIGHT='#ff005f'
RED_DARK='#af0000'

WALLPAPER=""
WALLPAPER_DEFAULT="$HOME/Bilder/Wallpapers/Wallpaper.png"

if [[ -z "$1" ]]; then
  if [[ -f "$WALLPAPER_DEFAULT" ]]; then
    echo "Use default wallpaper ($WALLPAPER_DEFAULT)"
    WALLPAPER="$WALLPAPER_DEFAULT"
  else
    echo "Missing wallpaper as first argument!"
    exit 1
  fi
else
  if [[ ! -f "$1" ]]; then
    echo "Can't find given wallpaper!"
    exit 1
  else
    WALLPAPER="$1"
  fi
fi

# Getting Started
i3lock \
  --nofork \
  --image "$WALLPAPER" \
  --tiling \
  --ignore-empty-password \
  --indicator \
  --clock \
  --keylayout=0 \
  --layoutcolor=${BLUE_MEDIUM}ff \
  --timestr="%H:%M" \
  --timecolor=${BLUE_LIGHT}ff \
  --datestr="%A, %d.%m.%Y" \
  --datecolor=${BLUE_LIGHT}ff \
  --radius=110 \
  --ring-width=9 \
  --line-uses-ring \
  --ringcolor="${BLUE_DARK}ff" \
  --insidecolor=${BLUE_DARK}22 \
  --separatorcolor=${BLUE_LIGHT}ff \
  --keyhlcolor=${BLUE_LIGHT}ff \
  --bshlcolor=${RED_DARK}ff \
  --veriftext="Correct...?" \
  --verifcolor=${GREEN_LIGHT}ff \
  --insidevercolor=${GREEN_LIGHT}22 \
  --ringvercolor=${GREEN_LIGHT}ff \
  --wrongtext="Nope!" \
  --noinputtext="Empty" \
  --insidewrongcolor=${RED_LIGHT}22 \
  --ringwrongcolor=${RED_DARK}ff \
  --wrongcolor=${RED_LIGHT}ff >>/tmp/testi.log 2>&1
