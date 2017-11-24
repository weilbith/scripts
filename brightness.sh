
#!/bin/bash

DIR=/sys/class/backlight/intel_backlight
FILE=$DIR/brightness
MIN_BRIGHTNESS=0
MAX_BRIGHTNESS=$(cat $DIR/max_brightness)
BRIGHTNESS=$(cat $FILE)

case "$1" in
    up)
        if [ $BRIGHTNESS -lt $MAX_BRIGHTNESS ]; then
            BRIGHTNESS=$(expr $BRIGHTNESS + 100)
        fi;;

    down)
        if [ $BRIGHTNESS -gt $MIN_BRIGHTNESS ]; then
            BRIGHTNESS=$(expr $BRIGHTNESS - 100)
        fi;;

    default)
        BRIGHTNESS=90;;

    *)
        echo "Unkown Pramater"; exit 1

esac

echo "echo $BRIGHTNESS > $FILE" | sudo bash

