#!/bin/bash

# Define the colors for the menu.
DEFAULT_BACKGROUND="#005f97"
DEFAULT_FOREGROUND="#ffffff"

SELECTED_BACKGROUND="#5fd7ff"
SELECTED_FOREGROUND="#282a2e"

# Define the DMenu
DMENU="dmenu -i -fn 'Calibri-10' -nb $DEFAULT_BACKGROUND -nf $DEFAULT_FOREGROUND -sb $SELECTED_BACKGROUND -sf $SELECTED_FOREGROUND -p GoTo: "$@""

name=$(i3-msg -t get_marks | tr -d '[],' | sed -e 's/""/\n/g' | tr -d '"' | $DMENU)
/usr/bin/i3-msg "[con_mark=$name]" focus
