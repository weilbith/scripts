#!/bin/bash
#
# Start the i3locker with specific color scheme.
#
# Arguments:
#   $1 - path to wallpaper
#

# Colors
LightBlue='#5fd7ff'
MediumBlue='#00afd7'
DarkBlue='#005f87'
LightGreen='#d7ff5f'
LightRed='#ff005f'
DarkRed='#af0000'


# Getting Started
i3lock \
  --nofork \
  --image "$1" \
  --tiling \
  --ignore-empty-password \
  --indicator \
  --clock \
  \
  --keylayout=0 \
  --layoutcolor=${MediumBlue}ff \
  \
  --timestr="%H:%M"  \
  --timecolor=${LightBlue}ff \
  --datestr="%A, %d.%m.%Y" \
  --datecolor=${LightBlue}ff \
  \
  --radius=110 \
  --ring-width=9 \
  \
  --line-uses-ring \
  --ringcolor="${DarkBlue}ff" \
  --insidecolor=${DarkBlue}22 \
  --separatorcolor=${LightBlue}ff \
  --keyhlcolor=${LightBlue}ff \
  --bshlcolor=${DarkRed}ff \
  \
  --veriftext="Correct...?" \
  --verifcolor=${LightGreen}ff \
  --insidevercolor=${LightGreen}22 \
  --ringvercolor=${LightGreen}ff \
  \
  --wrongtext="Nope!" \
  --noinputtext="Empty" \
  --insidewrongcolor=${LightRed}22 \
  --ringwrongcolor=${DarkRed}ff \
  --wrongcolor=${LightRed}ff
