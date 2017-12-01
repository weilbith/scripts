
#!/bin/bash

DIR=/sys/class/backlight/intel_backlight
FILE=$DIR/brightness
MIN_BRIGHTNESS=0
MAX_BRIGHTNESS=$(cat $DIR/max_brightness)
BRIGHTNESS=$(cat $FILE)
VALUE=100

# If second argument contains a value, it will be handled as brightness value to adjust.
if [ ! -z $2 ]
then
    VALUE=$2
fi


# Switch between the cases.
case "$1" in
    up)
        if [ $BRIGHTNESS -lt $MAX_BRIGHTNESS ]; then
            BRIGHTNESS=$(expr $BRIGHTNESS + $VALUE)
        fi;;

    down)
        if [ $BRIGHTNESS -gt $MIN_BRIGHTNESS ]; then
            BRIGHTNESS=$(expr $BRIGHTNESS - $VALUE)
        fi;;

    set)
        BRIGHTNESS=$VALUE;;

    default)
        BRIGHTNESS=90;;

    *)
        echo "Unkown Pramater"; exit 1

esac

echo "echo $BRIGHTNESS > $FILE" | sudo bash

