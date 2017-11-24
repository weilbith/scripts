#!/bin/zsh

# dmenu to change runstate using systemd

DMENU="dmenu -i -l 20 -fn 'Calibri-40'"
SYSTEMCTL="systemctl"

typeset -A CHOICES
CHOICES=(
    Shutdown    poweroff
    Reboot      reboot
    Hibernate   hibernate
    Suspend     suspend
    Halt        halt
)

CHOICE=$(print -l ${(k)CHOICES} | sort | ${=DMENU})

if [[ $? -eq 0 ]] then    
    ${=SYSTEMCTL} ${CHOICES[$CHOICE]}
fi
