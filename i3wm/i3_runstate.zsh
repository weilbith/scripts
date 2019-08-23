#!/bin/zsh

# Define the colors for the menu.
DEFAULT_BACKGROUND="#005f97"
DEFAULT_FOREGROUND="#ffffff"

SELECTED_BACKGROUND="#5fd7ff"
SELECTED_FOREGROUND="#282a2e"


# Define the DMenu with autofocus and case insensitive filter.
DMENU="dmenu -i -fn 'Calibri-10' -nb $DEFAULT_BACKGROUND -nf $DEFAULT_FOREGROUND -sb $SELECTED_BACKGROUND -sf $SELECTED_FOREGROUND -p Execute:"


# Define the menu entries to select.
typeset -A CHOICES
CHOICES=(
  Shutdown    poweroff
  Reboot      reboot
  Hibernate   hibernate
  Suspend     suspend
  Halt        halt
)

# Get the current selected menu entry.
CHOICE=$(print -l ${(k)CHOICES} | sort | ${=DMENU})

# Wait for hit return.
if [[ $? -eq 0 ]] then    
    systemctl ${CHOICES[$CHOICE]}
fi
