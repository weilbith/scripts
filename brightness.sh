#!/bin/bash

DIR=/sys/class/backlight/intel_backlight
FILE=$DIR/brightness
MIN_BRIGHTNESS=1 # Cause 0 is completetly black...
MAX_BRIGHTNESS=$(cat $DIR/max_brightness)
BRIGHTNESS=$(cat $FILE)
OLD_BRIGHTNESS=$BRIGHTNESS
VALUE=50

# If second argument contains a value, it will be handled as brightness value to adjust.
if [ ! -z $2 ]
then
    VALUE=$2
fi


# Switch between the cases.
case "$1" in
    up)
        BRIGHTNESS=$(expr $BRIGHTNESS + $VALUE)
       
        # Increasing over the maximum not possible and do nothing, so set to maximum.
        if [ $BRIGHTNESS -gt $MAX_BRIGHTNESS ]; then
          BRIGHTNESS=$MAX_BRIGHTNESS
        fi;;

    down)
        BRIGHTNESS=$(expr $BRIGHTNESS - $VALUE)

        # Decreasing under the minimum not possible and do nothing, so set to minimum.
        if [ $BRIGHTNESS -lt $MIN_BRIGHTNESS ]; then
          BRIGHTNESS=$MIN_BRIGHTNESS
        fi;;

    set)
        BRIGHTNESS=$VALUE;;

    default)
        BRIGHTNESS=90;;

    *)
        echo "Unkown Pramater"; exit 1

esac

# Do nothing if brightness stay the same by this action (e.g. increase still after reach maximum.
if [ $BRIGHTNESS -ne $OLD_BRIGHTNESS ] ; then 
  echo "echo $BRIGHTNESS > $FILE" | sudo bash
fi 
