#!/bin/bash

# settings
amount=0.1
max=1
min=0

# get deets
screen=`xrandr | grep 'primary' | awk '{ print $1 }'`
brightness=`xrandr  --verbose | grep -i brightness | awk '{ print $2 }'`

# variable passed
if [ $1 ]; then
    case  $1 in
        "+")
            brightness="$(echo $brightness+$amount | bc)"
            ;;
        "-")
            brightness="$(echo $brightness-$amount | bc)"
            ;;
    esac
fi

# check limits
if (( $(echo "$brightness > $max" | bc) )); then
    brightness=$max
fi
if (( $(echo "$brightness < $min" | bc) )); then
    brightness="$(echo ${min}+${amount} | bc)"  #toggle off/lowest
fi

# set brightness
xrandr --output ${screen} --brightness ${brightness}

# output
echo "
Usage:        `basename ${0}` [+/-]

Screen:       ${screen}
Brightness:   ${brightness}"
